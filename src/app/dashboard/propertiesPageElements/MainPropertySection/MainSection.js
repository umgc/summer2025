import React, { useState, useEffect } from "react";
import {
    Grid,
    Box,
    Divider,
    useTheme,
    useMediaQuery,
    Skeleton,
} from "@mui/material";
import { useLocation } from "react-router-dom";
import { motion } from "framer-motion";

//Custom Components
import MBPropertyMap from "../MapBox/MBMap";
import PropertyList from "./PropertyList";
import FilteringBar from "../FilteringBarSection/FilteringBar";
import FilteringBarMobile from "../FilteringBarSection/FilteringBarMobile";

import axios from "axios";
import config from "../../config";
const environment = process.env.NODE_ENV || "development";
const api = axios.create({
    baseURL: config[environment].apiUrl.replace("/api", ""),
});

export default function RealEstatePage({ appBarHeight }) {
    //Sizing
    const theme = useTheme();
    const isXl = useMediaQuery(theme.breakpoints.up("xl"));
    const isLg = useMediaQuery(theme.breakpoints.only("lg"));
    const isMd = useMediaQuery(theme.breakpoints.only("md"));
    const isSm = useMediaQuery(theme.breakpoints.only("sm"));
    const isXs = useMediaQuery(theme.breakpoints.only("xs"));

    //Get Button Dimensions
    const propertyListHeight = (() => {
        switch (true) {
            case isXl:
                return `calc(96vh - ${appBarHeight}px - ${appBarHeight}px)`; // Large screens
            case isLg:
                return `calc(96vh - ${appBarHeight}px - ${appBarHeight}px)`; // Large screens
            case isMd:
                return `calc(96vh - ${appBarHeight}px - ${appBarHeight}px)`; // Medium screens
            case isSm:
                return `calc(100vh - ${appBarHeight}px - ${appBarHeight}px - ${appBarHeight}px)`; // Small screens
            case isXs:
                return `calc(100vh - ${appBarHeight}px - ${appBarHeight}px)`; // Extra small screens
            default:
                return `calc(96vh - ${appBarHeight}px - ${appBarHeight}px)`; // Fallback size
        }
    })();

    const mapHeight = (() => {
        switch (true) {
            case isXl:
                return `calc(95vh - ${appBarHeight}px - ${appBarHeight}px)`; // Large screens
            case isLg:
                return `calc(95vh - ${appBarHeight}px - ${appBarHeight}px)`; // Large screens
            case isMd:
                return `calc(95vh - ${appBarHeight}px - ${appBarHeight}px)`; // Medium screens
            case isSm:
                return `calc(100vh - ${appBarHeight}px - ${appBarHeight}px - ${appBarHeight}px)`; // Small screens
            case isXs:
                return `calc(100vh - ${appBarHeight}px - ${appBarHeight}px - ${appBarHeight}px)`; // Extra small screens
            default:
                return `calc(95vh - ${appBarHeight}px - ${appBarHeight}px)`; // Fallback size
        }
    })();

    //Properties States
    const [originalProperties, setOriginalProperties] = useState([]);
    const [properties, setProperties] = useState([]);

    //Filtering
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedTypes, setSelectedTypes] = useState(['wholesale', 'turnkey', 'rental']);
    const [sortOrder, setSortOrder] = useState('most-relevant');
    const mobileMode = isXs ? "List" : "Map";
    const [selectedButton, setSelectedButton] = useState(mobileMode);

    //Search URL Query Parameters
    const location = useLocation();
    const searchParams = new URLSearchParams(location.search);
    const searchPropertyType = searchParams.get("type") || "";
    const searchAddress = searchParams.get("address") || "";

    //Loading Variables
    const [loadingProperties, setLoadingProperties] = useState(true);

    const formatPriceForSorting = (value) => {
        if (!value || value === "0" || value === 0) return 0; // Convert TBD prices to 0 for sorting
        return Number(String(value).replace(/,/g, "")) || 0; // Remove commas & convert to number
    };

    const formatPrice = (value) => {
        if (!value || value === "0" || value === 0) return "TBD"; // Handle undefined, empty, or zero values
        const num = Number(String(value).replace(/,/g, "")); // Remove commas and convert to number
        if (isNaN(num) || num === 0) return "TBD"; // Ensure 0 is "TBD"
        return `$${num.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    };

    const sortProperties = (properties, order) => {
        return [...properties].sort((a, b) => {
            if (order === "most-relevant") {
                return 0; // Keeps the original API order
            }

            if (order === "newest") {
                return new Date(b.date) - new Date(a.date); // Newest first
            }

            if (order === "oldest") {
                return new Date(a.date) - new Date(b.date); // Oldest first
            }

            // Determine the correct price to use for sorting
            const priceA = a.salemethod?.toLowerCase() === "rental" ? a.rentprice : a.price;
            const priceB = b.salemethod?.toLowerCase() === "rental" ? b.rentprice : b.price;

            if (order === "lowest") {
                return priceA - priceB; // Sort from lowest to highest
            } else {
                return priceB - priceA; // Sort from highest to lowest
            }
        });
    };

    const handleSortChange = (event) => {
        const newSortOrder = event.target.value;
        setSortOrder(newSortOrder);

        let sortedProperties;
        if (newSortOrder === "most-relevant") {
            sortedProperties = [...originalProperties]; // Restore original order
        } else {
            sortedProperties = sortProperties(properties, newSortOrder);
        }

        setProperties(sortedProperties);
    };

    //Intial Fetch of Properties
    //console.log("path1:", window.location.href);
    useEffect(() => {
        setLoadingProperties(true);
        setProperties([]);
        
        const fetchProperties = async () => {
            try {
                const response = await api.get("/api/properties", { headers: { 'Cache-Control': 'no-cache' } });

                let properties = response.data;
                if (location.pathname === "/sold-properties") {  //Filter for Sold properties
                    properties = properties.filter((obj) => obj.status === "sold");
                } else if (location.pathname === "/developments") {  //Filter for Development properties
                    properties = properties.filter((obj) => obj.salemethod === "development");
                } else {
                    // Exclude Sold and Development properties for other paths
                    properties = properties.filter((obj) => obj.status !== "sold" && obj.salemethod !== "development");
                }

                // Format properties with price and display price
                let formattedProperties = properties.map((property, index) => ({
                    ...property,
                    price: formatPriceForSorting(property.price),
                    rentprice: formatPriceForSorting(property.rentprice),
                    displayPrice: formatPrice(
                        property.salemethod === "rental" ? property.rentprice : property.price
                    ),
                    originalIndex: index, // Keep track of original order
                    photoUrl: "" // Placeholder, will be updated later
                }));

                // Fetch photo URLs in parallel
                const photoUrls = await Promise.all(
                    formattedProperties.map(async (property) => {
                        try {
                            const response = await api.post('/api/getFrontPhoto', {
                                address: property.address,
                            });
                            return response.data.photoUrl || ""; // Default to empty string if no photo found
                        } catch (error) {
                            console.error(`Error fetching photo for ${property.address}:`, error);
                            return ""; // Return empty string if API fails
                        }
                    })
                );

                // Attach the photo URLs to the corresponding properties
                formattedProperties = formattedProperties.map((property, index) => ({
                    ...property,
                    photoUrl: photoUrls[index], // Append fetched photo URL
                }));

                // Sort properties based on current sort order
                const sorted = sortProperties(formattedProperties, sortOrder);
                //setProperties(sorted);
                //setOriginalProperties(sorted);
                setProperties([...sorted]);
                setOriginalProperties([...sorted]);
                console.log("Properties Fetched:", sorted);
                setLoadingProperties(false);
            } catch (error) {
                console.error("Property Fetch Error:", error);
            }
        };

        fetchProperties();
    }, [location.pathname]);


    // Apply filters when properties are fetched or URL parameters change
    useEffect(() => {
        if (properties.length === 0) return;

        let filtered = [...properties];

        if (searchAddress) {
            setSearchQuery(searchAddress);
            filtered = filtered.filter((property) => {
                const propertyData = `${property.address} ${property.city} ${property.state} ${property.zip}`.toLowerCase();
                return propertyData.includes(searchAddress.toLowerCase());
            });
        }

        if (searchPropertyType) {
            const selectedTypesArray = [searchPropertyType.toLowerCase()];
            setSelectedTypes(selectedTypesArray);
            filtered = filtered.filter((property) => selectedTypesArray.includes(property.salemethod.toLowerCase()));
        }

        setProperties(filtered);
    }, [properties, searchAddress, searchPropertyType]);

    return (
        <Grid
            container
            sx={{
                mt: `${appBarHeight}px`,
                height: `calc(100vh - ${appBarHeight}px)`,
                overflow: "hidden",
                borderRadius: "10px",
            }}
        >
            <Grid
                item
                xs={12}
            >
                <FilteringBar
                    properties={properties}
                    setProperties={setProperties}
                    originalProperties={originalProperties}
                    selectedTypes={selectedTypes}
                    setSelectedTypes={setSelectedTypes}
                    searchQuery={searchQuery}
                    setSearchQuery={setSearchQuery}
                    sortOrder={sortOrder}
                    setSortOrder={setSortOrder}
                    selectedButton={selectedButton}
                    setSelectedButton={setSelectedButton}
                />
            </Grid>

            {/* Property List Section */}
            <motion.div
                variants={listVariants}
                initial="normal"
                animate={selectedButton === "Map" ? "normal" : "expanded"}
                style={{
                    display: "flex",
                    //height: "100%",
                    height: propertyListHeight,
                    backgroundColor: "white",
                    overflowY: "auto",
                    padding: "20px",
                }}
            >
                {loadingProperties ? (
                    renderSkeletons(selectedButton)
                ) : (
                    <PropertyList
                        key={location.pathname}
                        properties={properties}
                        sortOrder={sortOrder}
                        handleSortChange={handleSortChange}
                        selectedButton={selectedButton}
                        appBarHeight={appBarHeight}
                    />
                )}
            </motion.div>

            {/* Map Section */}
            <motion.div
                variants={mapVariants}
                initial="expanded"
                animate={selectedButton === "Map" ? "expanded" : "collapsed"}
                style={{
                    display: "flex",
                    //height: "100%",
                    height: mapHeight,
                    backgroundColor: "white",
                    overflow: "hidden",
                    borderRadius: "10px",
                }}
            >
                <MBPropertyMap properties={properties} />
            </motion.div>

        </Grid>
    );
}

// Skeleton Loader
const renderSkeletons = (selected) => (
    <Grid
        container
        spacing={4}
        sx={{
            px: { xs: 2, md: 5 },
            pt: 2,
        }}
    >
        <Skeleton
            variant="text"
            width="100%"
            height={150}
            sx={{ ml: 3 }}
        />

        {[...Array(12)].map((_, index) => (
            <Grid
                item
                xs={selected === "Map" ? 12 : 12}
                sm={selected === "Map" ? 12 : 6}
                md={selected === "Map" ? 12 : 4}
                lg={selected === "Map" ? 6 : 3}
                key={index}
            >
                <Box
                    sx={{
                        display: "flex",
                        flexDirection: "column",
                        boxShadow: 3,
                        overflow: "hidden",
                        backgroundColor: "white",
                    }}
                >
                    <Skeleton
                        variant="rectangular"
                        sx={{
                            height: {
                                xs: "70vw",
                                sm: "25vw",
                                md: "20vw",
                                lg: "14vw",
                                xl: "15vw",
                            },
                        }}
                    />
                    <Box sx={{ p: 2 }}>
                        <Skeleton variant="text" width="60%" height={30} />
                        <Skeleton variant="text" width="40%" height={20} sx={{ mb: 1 }} />
                        <Skeleton variant="text" width="80%" height={20} />
                        <Skeleton variant="text" width="50%" height={20} sx={{ mb: 2 }} />
                        <Skeleton variant="rectangular" width="50%" height={40} />
                    </Box>
                </Box>
            </Grid>
        ))}
    </Grid>
);

const mapVariants = {
    expanded: {
        width: "50%",
        opacity: 1,
        transition: {
            duration: 1,
        },
    },
    collapsed: {
        width: "0%",
        opacity: 0,
        transition: {
            duration: 1,
        },
    },
};

const listVariants = {
    expanded: {
        width: "100%",
        transition: {
            duration: 1,
        },
    },
    normal: {
        width: "50%",
        transition: {
            duration: 1,
        },
    },
};
