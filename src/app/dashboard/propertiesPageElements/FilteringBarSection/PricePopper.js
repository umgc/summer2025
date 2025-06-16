import React, { useState, useEffect } from "react";
import {
    Box,
    Typography,
    TextField,
    Button,
    Popper,
    Paper,
    ClickAwayListener,
    Slider,
} from "@mui/material";

export default function PricePopper({
    anchorEl,
    openPopper,
    handleClickAway,
    properties,
    setProperties,
    originalProperties
}) {
    const MIN_DISTANCE = 20000; // Minimum distance of $20K

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

    // **Handle Slider Movement (Enforcing $20K Minimum Distance)**
    const handlePriceChange = (event, newValue, activeThumb) => {
        if (!Array.isArray(newValue)) return;

        let [newMin, newMax] = newValue;

        if (activeThumb === 0) {
            newMin = Math.min(newMin, newMax - MIN_DISTANCE); // Prevent min > max
        } else {
            newMax = Math.max(newMax, newMin + MIN_DISTANCE); // Prevent max < min
        }

        setPriceRange([newMin, newMax]);
        filterProperties(newMin, newMax);
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
        <Popper open={openPopper === 'price'} anchorEl={anchorEl} placement="bottom-start" sx={{ zIndex: 10 }}>
            <ClickAwayListener onClickAway={handleClickAway}>
                <Paper
                    sx={{
                        p: 2,
                        position: 'relative',
                        width: { xs: '85vw', sm: '50vw', md: '80vw', lg: '80vw' },
                        maxWidth: { xs: '100%', sm: '500px' },
                    }}
                >
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
                </Paper>
            </ClickAwayListener>
        </Popper>
    );
}
