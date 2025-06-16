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
    ButtonGroup,
    useTheme,
    useMediaQuery,
} from "@mui/material";

//Icons
import SearchIcon from "@mui/icons-material/Search";
import ClearIcon from "@mui/icons-material/Clear";
import { KeyboardArrowDown, KeyboardArrowUp } from '@mui/icons-material';

//Custom Elements
import PricePopper from "./PricePopper";
import FilteringBarMobile from "./FilteringBarMobile";

export default function FilteringBar({
    properties,
    setProperties,
    originalProperties,
    selectedTypes,
    setSelectedTypes,
    searchQuery,
    setSearchQuery,
    selectedButton,
    setSelectedButton,
}) {
    //Sizing
    const theme = useTheme();
    const isXs = useMediaQuery(theme.breakpoints.only("xs"));

    //Filtering
    const [selectedBedrooms, setSelectedBedrooms] = useState("0+");
    const [selectedBathrooms, setSelectedBathrooms] = useState("0+");
    const [maxBedrooms, setMaxBedrooms] = useState(0);
    const [maxBathrooms, setMaxBathrooms] = useState(0);
    const [filters, setFilters] = useState({
        gender: [],
        size: [],
        color: [],
        price: [0, 999999] // Default price range
    });

    //Popper
    const [anchorEl, setAnchorEl] = useState(null);
    const [openPopper, setOpenPopper] = useState(null);

    useEffect(() => {
        if (originalProperties.length > 0) {
            const maxBeds = Math.max(...originalProperties.map(p => Number(p.bedrooms) || 0));
            const maxBaths = Math.max(...originalProperties.map(p => Number(p.bathrooms) || 0));

            setMaxBedrooms(maxBeds);  // Store as a number
            setMaxBathrooms(maxBaths);
        }
    }, [originalProperties]);

    const handleBedroomChange = (event) => {
        const selectedBeds = Number(event.target.value.replace("+", "")); // Convert string value to number
        setSelectedBedrooms(`${selectedBeds}+`);

        const filteredProperties = originalProperties.filter((property) =>
            Number(property.bedrooms) >= selectedBeds
        );

        setProperties(filteredProperties);
    };

    const handleBathroomChange = (event) => {
        const selectedBaths = Number(event.target.value.replace("+", "")); // Convert string value to number
        setSelectedBathrooms(`${selectedBaths}+`);

        const filteredProperties = originalProperties.filter((property) =>
            Number(property.bathrooms) >= selectedBaths
        );

        setProperties(filteredProperties);
    };


    const handleButtonClick = (event, popperId) => {
        event.preventDefault();
        event.stopPropagation();
        if (openPopper === popperId) {
            // If the popper is already open, close it
            setOpenPopper(null);
            setAnchorEl(null);
        } else {
            // Otherwise, open the specified popper
            setOpenPopper(popperId);
            setAnchorEl(event.currentTarget);
        }
    };

    const handleClickAway = () => {
        setOpenPopper(null);
    };

    //Handle Sale Type Change
    const handleTypeChange = (event) => {
        const selectedType = event.target.value;

        let saleType = []
        // Toggle the selected type
        if (selectedTypes.includes(selectedType)) {
            saleType = selectedTypes.filter((type) => type !== selectedType)
            setSelectedTypes(saleType);
        } else {
            saleType = selectedType;
            setSelectedTypes(saleType);
        }

        const filteredProperties = originalProperties.filter((property) =>
            saleType.includes(property.salemethod)
        );
        setProperties(filteredProperties);
    };

    const handleSearchChange = (event) => {
        const query = event.target.value.toLowerCase();
        setSearchQuery(query);

        if (!query) {
            setProperties(originalProperties); // Reset when search is cleared
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
        setProperties(originalProperties); // Restore all properties
    };

    // Formats price range as "$0K - $999K"
    const formatPriceRange = () => {
        const formatNumber = (num) => {
            if (num >= 1000000) {
                return `$999K`; // Cap at 999K instead of showing 1000K
            } else if (num >= 1000) {
                return `$${Math.min(Math.floor(num / 1000), 999)}K`; // Ensure max 999K
            }
            return `$${num}`; // Below 1,000 -> $999
        };

        return `${formatNumber(filters.price[0])} - ${formatNumber(filters.price[1])}`;
    };

    return (
        <>
            {isXs ? (
                <FilteringBarMobile
                    properties={properties}
                    setProperties={setProperties}
                    originalProperties={originalProperties}
                    selectedTypes={selectedTypes}
                    setSelectedTypes={setSelectedTypes}
                    searchQuery={searchQuery}
                    setSearchQuery={setSearchQuery}
                    selectedButton={selectedButton}
                    handleBathroomChange={handleBathroomChange}
                    handleBedroomChange={handleBedroomChange}
                    selectedBathrooms={selectedBathrooms}
                    selectedBedrooms={selectedBedrooms}
                    selectedType={selectedTypes}
                    handleTypeChange={handleTypeChange}
                />
            ) : (
                <Grid
                    container
                    spacing={{
                        xs: 2,
                        md: 3,
                        xl: 5,
                    }}
                    sx={{
                        px: 3,
                        pt: 3,
                    }}
                >
                    <Grid item xs={8} md={4} xl={4}>
                        <TextField
                            size="normal"
                            label={
                                <div style={{ marginLeft: '35px' }}>
                                    Search by address, city, state, zip ...
                                </div>
                            }
                            variant="outlined"
                            value={searchQuery}
                            onChange={handleSearchChange}
                            sx={{
                                width: "100%",
                                //"& .MuiInputBase-root": { height: "60px" }, // Increase height
                                // "& .MuiOutlinedInput-input": { fontSize: "1.2rem", padding: "14px" }, // Increase font & padding
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
                            InputLabelProps={{
                                shrink: searchQuery !== '',
                                sx: { fontSize: "1.2rem" } // Make label bigger
                            }}
                        />
                    </Grid>

                    <Grid item xs={4} md={2} xl={1.5}>
                        <TextField
                            label="Price Range"
                            variant="outlined"
                            fullWidth
                            value={formatPriceRange()} // Displays formatted range
                            onClick={(event) => handleButtonClick(event, 'price')}
                            InputProps={{
                                endAdornment: (
                                    <InputAdornment position="end">
                                        <IconButton>
                                            {openPopper ? <KeyboardArrowUp /> : <KeyboardArrowDown />}
                                        </IconButton>
                                    </InputAdornment>
                                )
                            }}
                            sx={{ cursor: "pointer", backgroundColor: "white" }} // Makes it look like a button
                        />
                        <PricePopper
                            anchorEl={anchorEl}
                            openPopper={openPopper}
                            handleClickAway={handleClickAway}
                            properties={properties}
                            setProperties={setProperties}
                            originalProperties={originalProperties}
                        />
                    </Grid>

                    <Grid item xs={3} md={1.5} lg={1.5} xl={1}>
                        <FormControl fullWidth variant="outlined" sx={{ mb: 2 }}>
                            <InputLabel> Sale Type</InputLabel>
                            <Select
                                label="Sale Type"
                                multiple
                                value={selectedTypes}
                                onChange={handleTypeChange}
                                renderValue={(selected) => `${selected.length} Types`}
                                sx={{ minWidth: '100px' }} // Set the width as desired
                            >
                                <MenuItem value="wholesale">
                                    <Checkbox checked={selectedTypes.includes('wholesale')} />
                                    <ListItemText primary="Wholesale" />
                                </MenuItem>
                                <MenuItem value="rental">
                                    <Checkbox checked={selectedTypes.includes('rental')} />
                                    <ListItemText primary="Rental" />
                                </MenuItem>
                                <MenuItem value="turnkey">
                                    <Checkbox checked={selectedTypes.includes('turnkey')} />
                                    <ListItemText primary="Turnkey" />
                                </MenuItem>
                            </Select>
                        </FormControl>
                    </Grid>

                    <Grid item xs={3} md={1.5} lg={1.5} xl={1}>
                        <FormControl fullWidth>
                            <InputLabel>Bedrooms</InputLabel>
                            <Select
                                value={selectedBedrooms}
                                onChange={handleBedroomChange}
                                label="Bedrooms"
                            >
                                {[...Array(Math.ceil(maxBedrooms) + 1).keys()].map((num) => (
                                    <MenuItem key={num} value={`${num}+`}>{num}+ Beds</MenuItem>
                                ))}
                            </Select>
                        </FormControl>
                    </Grid>

                    <Grid item xs={3} md={1.5} lg={1.5} xl={1}>
                        <FormControl fullWidth>
                            <InputLabel>Bathrooms</InputLabel>
                            <Select
                                value={selectedBathrooms}
                                onChange={handleBathroomChange}
                                label="Bathrooms"
                            >
                                {[...Array(Math.ceil(maxBathrooms) + 1).keys()].map((num) => (
                                    <MenuItem key={num} value={`${num}+`}>{num}+ Baths</MenuItem>
                                ))}
                            </Select>
                        </FormControl>
                    </Grid>

                    <Grid item xs={3} md={1.5} lg={1.5} xl={3.5}
                        sx={{
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "right",
                            pb: 2,
                        }}
                    >
                        <ButtonGroup
                            variant="contained"
                            aria-label="Property Type Button Group"
                            disableElevation // Removes shadow
                            disableRipple // Removes ripple effect
                            sx={{
                                borderRadius: "30px",
                                boxShadow: "none", // Removes ButtonGroup shadow
                                overflow: "hidden",
                                border: "none", // Removes ButtonGroup border
                                "& .MuiButtonGroup-grouped": {
                                    border: "none !important", // Ensures no dividers
                                },
                                backgroundColor: "#D3D3D3",
                            }}
                        >
                            {["List", "Map"].map((buttonName) => (
                                <Button
                                    key={buttonName}
                                    sx={buttonStyling(buttonName, selectedButton)}
                                    onClick={() => setSelectedButton(buttonName)} // Change selection on click
                                >
                                    {buttonName}
                                </Button>
                            ))}
                        </ButtonGroup>
                    </Grid>

                </Grid>
            )}
        </>
    );
}

const buttonStyling = (buttonName, selectedButton) => ({
    fontSize: {
        xs: "1vw",
        sm: '2.5vw',
        md: '1.75vw',
        lg: "1.3vw",
        xl: ".9vw"
    },
    fontFamily: "Poppins",
    fontWeight: 400,
    borderRadius: "30px !important", // Force border-radius
    backgroundColor: selectedButton === buttonName ? "#ad0800" : "#D3D3D3", // Selected button color
    color: selectedButton === buttonName ? "white" : "black", // Adjust text color
    border: "none", // Remove internal button border
    boxShadow: "none", // Remove shadows
    "&:hover": {
        backgroundColor: "#f1dfbb", // Hover effect
        color: "black", // Adjust text colorborder
    },
    textTransform: "capitalize",
});