import React, { useState, useEffect } from 'react';
import AWS from 'aws-sdk';
import {
    Typography,
    Card,
    CardContent,
    CardActionArea,
    CardMedia,
    Box,
    Grid,
    Tooltip,
    useTheme,
    useMediaQuery,
    Button,
    IconButton,
} from '@mui/material';
import { motion, useTransform } from "framer-motion";
import { Link } from 'react-router-dom';
import { useNavigate } from 'react-router-dom';

//Icons
import { ArrowOutward } from '@mui/icons-material';

// Set the base URL for Axios requests
import axios from 'axios';
import config from '../../config';
import { Bathtub, Bed, Place } from '@mui/icons-material';
const environment = process.env.NODE_ENV || 'development';  // Determine the environment (e.g., development or production)
const api = axios.create({
    baseURL: config[environment].apiUrl.replace('/api', ''),
});

function PropertyCard({ property }) {
    const navigate = useNavigate();

    const secondaryTextColor = "#f1dfbb";
    const redColor = "#ad0800";

    const [photoUrl, setPhotoUrl] = useState([]);
    const alignment = {
        xs: "center",
        sm: "left"
    };

    const theme = useTheme();
    const isXl = useMediaQuery(theme.breakpoints.up("xl"));
    const isLg = useMediaQuery(theme.breakpoints.only("lg"));
    const isMd = useMediaQuery(theme.breakpoints.only("md"));
    const isSm = useMediaQuery(theme.breakpoints.only("sm"));
    const isXs = useMediaQuery(theme.breakpoints.only("xs"));
    const isXlDown = useMediaQuery(theme.breakpoints.down("xl"));

    //Get Button Dimensions
    const buttonDimensions = (() => {
        switch (true) {
            case isXl:
                return "1.75vw"; // Large screens
            case isLg:
                return "50px"; // Large screens
            case isMd:
                return "55px"; // Medium screens
            case isSm:
                return "7vw"; // Small screens
            case isXs:
                return "10vw"; // Extra small screens
            default:
                return "50px"; // Fallback size
        }
    })();

    //Get Icon Dimensions
    const iconDimensions = (() => {
        switch (true) {
            case isXl:
                return "1.5vw"; // Large screens
            case isLg:
                return 30; // Large screens
            case isMd:
                return 35; // Medium screens
            case isSm:
                return "3.5vw"; // Small screens
            case isXs:
                return "7vw"; // Extra small screens
            default:
                return 30; // Fallback size
        }
    })();

    useEffect(() => {
        const getPhotoUrl = async () => {
            const response = await api.post('/api/getFrontPhoto', {
                address: property.address,
            });
            setPhotoUrl(response.data.photoUrl);
        }
        getPhotoUrl()
    }, [property.address]);

    const handleCardClick = () => {
        // Navigate to the PropertyDetail page and pass the property object as state
        navigate(`/properties/${property.address.replace(/ /g, "-").replace(/[^a-zA-Z0-9-]/g, "").toLowerCase()}`, { state: { property } });
    };

    // Function to format price correctly (handles already formatted strings)
    const formatPrice = (value) => {
        if (!value || value === "0" || value === 0) return "TBD"; // Handle undefined, empty, or zero values
        const num = Number(String(value).replace(/,/g, "")); // Remove commas and convert to number
        if (isNaN(num) || num === 0) return "TBD"; // Handle invalid numbers and ensure 0 is "TBD"
        return `$${num.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    };

    // Converts fractions like "3/2" to decimals like 1.5
    const convertFractionToDecimal = (value) => {
        if (typeof value === 'string' && value.includes('/')) {
            const [numerator, denominator] = value.split('/').map(Number);
            return (numerator / denominator).toFixed(1).replace('.0', '');
        }
        return Number(value).toFixed(1).replace('.0', '');  // Handles normal numbers
    };


    return (
        <motion.div
            whileHover={{
                scale: 1.05,
            }}
            transition={{ duration: 0.5, ease: "easeOut" }}
        >
            <Card
                sx={{
                    width: '100%',
                    boxShadow: 3,
                    borderRadius: "3%",
                    backgroundColor: 'white', // Ensure transparency
                    "&:hover": {
                        border: `3px solid ${redColor}`,
                    },

                }}
            >
                <CardActionArea onClick={handleCardClick}>
                    <CardMedia
                        component="img"
                        image={photoUrl}
                        sx={{
                            height: {
                                xs: "70vw",
                                sm: "25vw",
                                md: "20vw",
                                lg: "14vw",
                                xl: "15vw",
                            }
                        }}
                    />

                    {property.status === "sold" && (
                        <Box
                            component="img"
                            src="/images/sold-seal-red-nobck.png"  // Path to your "Sold" image in the public folder
                            alt="Sold"
                            sx={{
                                position: "absolute",
                                top: {
                                    xs: "25%", 
                                    lg: "30%",
                                },
                                left: "50%",
                                transform: "translate(-50%, -50%)",
                                width: "80%",  // Adjust size as needed
                                opacity: 1,  // Adjust transparency if needed
                                pointerEvents: "none",  // Ensure overlay does not block clicks
                            }}
                        />
                    )}

                    <Box
                        sx={{
                            background: 'black',
                            color: 'white',
                            textAlign: 'center',
                            padding: '15px 0',
                        }}
                    >
                        {property.salemethod && (
                            <Typography
                                sx={{
                                    textAlign: "center",
                                    fontSize: {
                                        xs: "5vw",
                                        sm: '2vw',
                                        md: '1.5vw',
                                        lg: "1.1vw",
                                        xl: ".9vw",
                                    },
                                    fontWeight: 300,
                                    fontFamily: "Montserrat",
                                    lineHeight: { xs: '1.05', md: '1' },
                                }}
                            >
                                {property.salemethod.charAt(0).toUpperCase() + property.salemethod.slice(1)}
                            </Typography>
                        )}
                    </Box>

                    <CardContent
                        sx={{
                            backgroundColor: 'white', // Ensure CardContent is also transparent
                            //backdropFilter: "blur(0px)", // Ensures no overlay effect
                            color: "black", // Ensures text visibility
                        }}
                    >
                        <Grid container rowSpacing={0} columnSpacing={0} sx={{ mx: 1, mt: 1 }}>
                            <Grid item xs={12}>
                                {/* Rental Price */}
                                {property.salemethod && property.salemethod.toLowerCase() === "rental" && (
                                    <Typography
                                        sx={{
                                            textAlign: alignment,
                                            fontSize: {
                                                xs: "7vw",
                                                sm: "3vw",
                                                md: "2.25vw",
                                                lg: "1.75vw",
                                                xl: "1.5vw",
                                            },
                                            fontWeight: 500,
                                            fontFamily: "Poppins",
                                            lineHeight: { xs: "1.05", md: "1" },
                                        }}
                                    >
                                        {formatPrice(property.rentprice)}/month
                                    </Typography>
                                )}

                                {/* Sale Price (Wholesale, Turnkey) */}
                                {["wholesale", "turnkey"].includes(property.salemethod?.toLowerCase()) && (
                                    <Typography
                                        sx={{
                                            textAlign: alignment,
                                            fontSize: {
                                                xs: "7vw",
                                                sm: "3vw",
                                                md: "2.25vw",
                                                lg: "1.75vw",
                                                xl: "1.5vw",
                                            },
                                            fontWeight: 500,
                                            fontFamily: "Poppins",
                                            lineHeight: { xs: "1.05", md: "1" },
                                        }}
                                    >
                                        {formatPrice(property.price)}
                                    </Typography>
                                )}
                            </Grid>


                            <Grid item xs={6} sm={3} md={2.5} lg={2.5} xl={2}
                                sx={{
                                    display: "flex",
                                    justifyContent: { xs: "right", sm: "left" },
                                    pr: { xs: 2, sm: 0 }
                                }}
                            >
                                <Typography
                                    sx={{
                                        textAlign: {
                                            xs: "right",
                                            sm: alignment
                                        },
                                        fontSize: {
                                            xs: "7vw",
                                            sm: '2.25vw',
                                            md: '2vw',
                                            lg: "1.25vw",
                                            xl: "1vw",
                                        },
                                        fontWeight: 400,
                                        fontFamily: "Montserrat",
                                        mt: 1,
                                        display: "flex",
                                        alignItems: "center"
                                    }}
                                >
                                    <Bed
                                        sx={{
                                            fontSize: {
                                                xs: "7vw",
                                                sm: '2.25vw',
                                                md: '2.25vw',
                                                lg: "1.3vw"
                                            },
                                            verticalAlign: "middle",
                                            mr: 1
                                        }}
                                    />
                                    {convertFractionToDecimal(property.bedrooms)}
                                </Typography>
                            </Grid>

                            <Grid item xs={6} sm={3} md={2.5} lg={2.5} xl={2}>
                                <Typography
                                    sx={{
                                        textAlign: alignment,
                                        fontSize: {
                                            xs: "7vw",
                                            sm: '2.25vw',
                                            md: '2.25vw',
                                            lg: "1.25vw",
                                            xl: "1vw",
                                        },
                                        fontWeight: 400,
                                        fontFamily: "Montserrat",
                                        mt: 1,
                                        display: "flex",
                                        alignItems: "center"
                                    }}
                                >
                                    <Bathtub
                                        sx={{
                                            fontSize: {
                                                xs: "7vw",
                                                sm: '2.25vw',
                                                md: '2vw',
                                                lg: "1.3vw"
                                            },
                                            verticalAlign: "middle",
                                            mr: { xs: 1, lg: 1 }
                                        }}
                                    />
                                    {convertFractionToDecimal(property.bathrooms)}
                                </Typography>
                            </Grid>

                            <Grid item xs={12} lg={12} xl={9}>
                                {property.address && (
                                    <>
                                        {/* Address */}
                                        <Typography
                                            sx={{
                                                textAlign: { xs: "center", sm: "left" },
                                                fontSize: {
                                                    xs: "6vw",
                                                    sm: "2.25vw",
                                                    md: "1.75vw",
                                                    lg: "1.2vw",
                                                    xl: ".8vw",
                                                },
                                                fontWeight: 400,
                                                fontFamily: "Montserrat",
                                                lineHeight: { xs: "1.05", md: "1" },
                                                mt: 1,
                                                ml: { xs: -4, sm: -0.5 },
                                                display: { xs: "block", sm: "flex" },
                                                alignItems: "center",
                                            }}
                                        >
                                            <Place
                                                sx={{
                                                    fontSize: {
                                                        xs: "7vw",
                                                        sm: "2.25vw",
                                                        md: "2vw",
                                                        lg: "1vw"
                                                    },
                                                    marginRight: "5px"
                                                }}
                                            />
                                            {property.address}
                                        </Typography>

                                        {/* City, State, Zip */}
                                        <Typography
                                            sx={{
                                                textAlign: { xs: "center", sm: "left" },
                                                fontSize: {
                                                    xs: "5vw",
                                                    sm: "2.25vw",
                                                    md: "1.75vw",
                                                    lg: "1.2vw",
                                                    xl: ".8vw",
                                                },
                                                fontWeight: 400,
                                                fontFamily: "Montserrat",
                                                lineHeight: "1",
                                                mt: 0.5,
                                                ml: { xs: 0, lg: 2, xl: 3 },
                                                display: "block",
                                            }}
                                        >
                                            {property.city}, {property.state} {property.zip}
                                        </Typography>
                                    </>
                                )}
                            </Grid>

                            {/* Button Container: Pushes Button to the Bottom */}
                            {!isXlDown && (
                                <Grid
                                    item
                                    xs={3}
                                    sx={{
                                        display: "flex",
                                        justifyContent: "flex-end",
                                        alignItems: "flex-end", // Ensures the button is at the bottom
                                        height: "100%",
                                        mt: "auto",
                                        pr: 2,
                                    }}
                                >
                                    <Tooltip title="View Property" placement="bottom">
                                        <motion.div
                                            whileHover={{ scale: 1.1 }}
                                            transition={{ duration: 0.2, ease: "easeOut" }}
                                        >
                                            <Button
                                                onClick={handleCardClick}
                                                variant="contained"
                                                sx={{
                                                    backgroundColor: "white",
                                                    color: "black",
                                                    border: "2px solid black",
                                                    borderRadius: "5%",
                                                    minWidth: buttonDimensions,
                                                    height: buttonDimensions,
                                                    display: "flex",
                                                    alignItems: "center",
                                                    justifyContent: "center",
                                                    gap: "4px",
                                                    "&:hover": {
                                                        backgroundColor: secondaryTextColor,
                                                        color: "black",
                                                    },
                                                }}
                                            >
                                                <Typography
                                                    sx={{
                                                        fontSize: { xs: "1.25vw", sm: "2vw", md: "1.75vw", lg: "1vw" },
                                                        fontWeight: 500,
                                                        fontFamily: "Montserrat",
                                                        lineHeight: "1",
                                                    }}
                                                >
                                                    View
                                                </Typography>
                                                <ArrowOutward sx={{ fontSize: iconDimensions, transition: "color 0.2s" }} />
                                            </Button>
                                        </motion.div>
                                    </Tooltip>
                                </Grid>
                            )}

                        </Grid>
                    </CardContent>
                </CardActionArea>
            </Card>
        </motion.div >
    );
}

export default PropertyCard;
