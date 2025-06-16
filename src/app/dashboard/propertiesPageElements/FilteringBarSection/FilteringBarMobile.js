import React, { useState, useEffect } from "react";
import {
    Box,
    Grid,
    Typography,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
    TextField,
    InputAdornment,
    IconButton,
    Button,
    Popper,
    Paper,
    ClickAwayListener,
    Slider,
    Checkbox,
    ListItemText,
    Drawer,
    Accordion,
    AccordionSummary,
    AccordionDetails,
} from "@mui/material";

// Icons
import SearchIcon from "@mui/icons-material/Search";
import ClearIcon from "@mui/icons-material/Clear";
import FilterListIcon from "@mui/icons-material/FilterList";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";

// Custom Elements
import PricePopper from "./PricePopper";

export default function FilteringBarMobile({
    properties,
    setProperties,
    originalProperties,
    selectedTypes,
    setSelectedTypes,
    searchQuery,
    setSearchQuery,
    handleBathroomChange,
    handleBedroomChange,
    selectedBathrooms,
    selectedBedrooms,
    handleTypeChange,
}) {

    // Filtering States
    const MIN_DISTANCE = 20000; // Minimum distance of $20K
    const [maxBedrooms, setMaxBedrooms] = useState(0);
    const [maxBathrooms, setMaxBathrooms] = useState(0);
    const [drawerOpen, setDrawerOpen] = useState(false);
    //const [priceRange, setPriceRange] = useState([0, 999999]);

    // **Determine Dynamic Max Price**
    const maxPropertyPrice = Math.max(
        ...originalProperties.map((p) =>
            p.salemethod?.toLowerCase() === "rental" ? p.rentprice : p.price
        )
    );
    const [priceRange, setPriceRange] = useState([0, maxPropertyPrice]);

    useEffect(() => {
        setPriceRange([0, maxPropertyPrice]); // Update when properties change
    }, [maxPropertyPrice]);

    // **Format numbers into K format (e.g., $250K)**
    const formatToK = (num) => (num >= 1000 ? `${Math.round(num / 1000)}K` : num);

    // **Dynamically Generated Marks (Static Intervals, Dynamic Max)**
    const generateMarks = () => {
        const numMarks = 5;
        const step = maxPropertyPrice / numMarks;
        return [...Array(numMarks + 1)].map((_, i) => {
            const value = Math.round(step * i);
            return { value, label: `$${formatToK(value)}` };
        });
    };

    const marks = generateMarks();

    useEffect(() => {
        if (originalProperties.length > 0) {
            const maxBeds = Math.max(...originalProperties.map(p => Number(p.bedrooms) || 0));
            const maxBaths = Math.max(...originalProperties.map(p => Number(p.bathrooms) || 0));
            const maxPrice = Math.max(...originalProperties.map(p => Number(p.price) || 0));
            setMaxBedrooms(maxBeds);
            setMaxBathrooms(maxBaths);
            setPriceRange([0, maxPrice]);
        }
    }, [originalProperties]);

    const handlePriceChange = (event, newValue) => {
        setPriceRange(newValue);
        const filteredProperties = originalProperties.filter((property) =>
            Number(property.price) >= newValue[0] && Number(property.price) <= newValue[1]
        );
        setProperties(filteredProperties);
    };

    // Handle Drawer Toggle
    const toggleDrawer = () => setDrawerOpen(!drawerOpen);

    const handleSearchChange = (event) => {
        const query = event.target.value.toLowerCase();
        setSearchQuery(query);

        if (!query) {
            setProperties(originalProperties);
            return;
        }

        const filteredProperties = originalProperties.filter((property) => {
            const propertyData = `${property.address} ${property.city} ${property.state} ${property.zip}`.toLowerCase();
            return propertyData.includes(query);
        });

        setProperties(filteredProperties);
    };

    const clearSearch = () => {
        setSearchQuery('');
        setProperties(originalProperties);
    };

    // **Handle Manual Min Price Input**
    const handleMinPriceChange = (event) => {
        let newMinPrice = Number(event.target.value);
        if (newMinPrice >= priceRange[1] - MIN_DISTANCE) return; // Prevent min >= max

        setPriceRange([newMinPrice, priceRange[1]]);
        filterProperties(newMinPrice, priceRange[1]);
    };

    // **Handle Manual Max Price Input**
    const handleMaxPriceChange = (event) => {
        let newMaxPrice = Number(event.target.value);
        if (newMaxPrice <= priceRange[0] + MIN_DISTANCE) return; // Prevent max <= min

        setPriceRange([priceRange[0], newMaxPrice]);
        filterProperties(priceRange[0], newMaxPrice);
    };

    // **Filter Properties based on updated price range**
    const filterProperties = (minPrice, maxPrice) => {
        const filteredProperties = originalProperties.filter((property) => {
            const propertyPrice =
                property.salemethod?.toLowerCase() === "rental"
                    ? property.rentprice
                    : property.price;
            return propertyPrice >= minPrice && propertyPrice <= maxPrice;
        });

        setProperties(filteredProperties);
    };

    // **Reset Price Filter to Default**
    const handleResetPrice = () => {
        setPriceRange([0, maxPropertyPrice]);
        setProperties(originalProperties); // Restore original properties
    };

    return (
        <>
            {/* Search Bar */}
            <Box
                sx={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                    padding: "10px",
                    backgroundColor: "#f5f5f5",
                }}
            >
                <TextField
                    size="small"
                    placeholder="Search by address, city, state, zip..."
                    variant="outlined"
                    value={searchQuery}
                    onChange={handleSearchChange}
                    sx={{
                        width: "100%",
                        backgroundColor: "white",
                    }}
                    InputProps={{
                        startAdornment: (
                            <InputAdornment position="start">
                                <SearchIcon />
                            </InputAdornment>
                        ),
                        endAdornment: (
                            <InputAdornment position="end">
                                {searchQuery && (
                                    <IconButton onClick={clearSearch} edge="end">
                                        <ClearIcon />
                                    </IconButton>
                                )}
                            </InputAdornment>
                        ),
                    }}
                />
                <IconButton onClick={toggleDrawer} sx={{ marginLeft: "10px" }}>
                    <FilterListIcon />
                </IconButton>
            </Box>

            {/* Drawer for Filters */}
            <Drawer
                anchor="bottom"
                open={drawerOpen}
                onClose={toggleDrawer}
                PaperProps={{ sx: { height: "75vh", overflow: "auto" } }}
            >
                <Box sx={{ padding: 2 }}>
                    <Typography variant="h6" sx={{ mb: 2, textAlign: "center" }}>
                        Filter Options
                    </Typography>

                    {/* Price Filter Accordion */}
                    <Accordion>
                        <AccordionSummary expandIcon={<ExpandMoreIcon />}>
                            <Typography>Price Range</Typography>
                        </AccordionSummary>
                        <AccordionDetails>
                            <Box sx={{ mb: 2, px: 3 }}>
                                {/* Min and Max Price Inputs */}
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 0 }}>
                                    <TextField
                                        label="Min"
                                        type="number"
                                        value={priceRange[0]}
                                        onChange={handleMinPriceChange}
                                        sx={{ width: { xs: '45%', sm: '45%' } }}
                                        InputLabelProps={{ sx: { color: 'black' } }}
                                    />
                                    <Typography sx={{ mx: { xs: 1, sm: 1 }, fontSize: { xs: '10vw', sm: '2vw' } }}>
                                        -
                                    </Typography>
                                    <TextField
                                        label="Max"
                                        type="number"
                                        value={priceRange[1]}
                                        onChange={handleMaxPriceChange}
                                        sx={{ width: { xs: '45%', sm: '45%' } }}
                                        InputLabelProps={{ sx: { color: 'black' } }}
                                    />
                                </Box>

                                {/* Price Range Slider */}
                                <Slider
                                    value={priceRange}
                                    onChange={handlePriceChange}
                                    valueLabelDisplay="auto"
                                    min={0}
                                    max={maxPropertyPrice}
                                    marks={marks} // **Dynamic Max Value**
                                    sx={{ '& .MuiSlider-markLabel': { color: 'black' } }}
                                />
                            </Box>

                            {/* Reset Price Button */}
                            <Box sx={{ position: 'absolute', bottom: 0, left: 8, right: 8 }}>
                                <Button onClick={handleResetPrice} variant="text" sx={{ textDecoration: 'underline' }}>
                                    Clear
                                </Button>
                            </Box>
                        </AccordionDetails>
                    </Accordion>

                    {/* Sale Type Accordion */}
                    <Accordion>
                        <AccordionSummary expandIcon={<ExpandMoreIcon />}>
                            <Typography>Sale Type</Typography>
                        </AccordionSummary>
                        <AccordionDetails>
                            <FormControl fullWidth variant="outlined">
                                <InputLabel>Sale Type</InputLabel>
                                <Select
                                    label="Sale Type"
                                    multiple
                                    value={selectedTypes}
                                    onChange={handleTypeChange}
                                    renderValue={(selected) => `${selected.length} Types`}
                                >
                                    {["wholesale", "rental", "turnkey"].map((type) => (
                                        <MenuItem key={type} value={type}>
                                            <Checkbox checked={selectedTypes.includes(type)} />
                                            <ListItemText primary={type.charAt(0).toUpperCase() + type.slice(1)} />
                                        </MenuItem>
                                    ))}
                                </Select>
                            </FormControl>
                        </AccordionDetails>
                    </Accordion>

                    {/* Bedrooms Accordion */}
                    <Accordion>
                        <AccordionSummary expandIcon={<ExpandMoreIcon />}>
                            <Typography>Rooms</Typography>
                        </AccordionSummary>
                        <AccordionDetails>
                            <FormControl fullWidth variant="outlined">
                                <InputLabel>Bedrooms</InputLabel>
                                <Select
                                    label="Bedrooms"
                                    value={selectedBedrooms}
                                    onChange={handleBedroomChange}
                                >
                                    {[...Array(Math.ceil(maxBedrooms) + 1).keys()].map((num) => (
                                        <MenuItem key={num} value={`${num}+`}>{num}+ Beds</MenuItem>
                                    ))}
                                </Select>
                            </FormControl>

                            <FormControl fullWidth variant="outlined" sx={{mt: 3}}>
                                <InputLabel>Bathrooms</InputLabel>
                                <Select
                                    label="Bathrooms"
                                    value={selectedBathrooms}
                                    onChange={handleBathroomChange}
                                >
                                    {[...Array(Math.ceil(maxBedrooms) + 1).keys()].map((num) => (
                                        <MenuItem key={num} value={`${num}+`}>{num}+ Baths</MenuItem>
                                    ))}
                                </Select>
                            </FormControl>
                        </AccordionDetails>
                    </Accordion>

                </Box>
            </Drawer>
        </>
    );
}
