import React, { useState, useEffect, useRef } from "react";
import {
    Box,
    Grid,
    Typography,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
} from "@mui/material";

//Custom Components
import PropertyCard from "../PropertyCards/PropertyCard";

export default function PropertyList({
    properties,
    sortOrder,
    handleSortChange,
    selectedButton,
    appBarHeight,
}) {

    const listSize = selectedButton === "Map" ? 6 : 3;
    const listSizeMd = selectedButton === "Map" ? 12 : 4;
    const listSizeSm = selectedButton === "Map" ? 12 : 6;
    
    return (
        <Box
            sx={{
                display: "flex",
                width: "100%",
                height: `100%`,
                overflowY: "auto",
                px: { xs: 2, lg: 5 },
                //pt: 5,
            }}
        >
            <Grid container rowSpacing={3} columnSpacing={{ xs: 3, lg: 3, xl: 5 }}>
                <Grid item xs={12} sm={selectedButton === "Map" ? 12 : 8} lg={8} xl={9}
                    sx={{
                        display: "flex",
                        alignItems: "center",
                        justifyContent: { xs: "center", sm: "flex-start" },
                    }}
                >
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: {
                                xs: "8vw",
                                sm: '3.5vw',
                                md: '3.5vw',
                                lg: "2.5vw",
                                xl: "2vw",
                            },
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                            lineHeight: { xs: '1.05', md: '1' },
                        }}
                    >
                        {properties.length} Properties Found
                    </Typography>
                </Grid>

                <Grid item xs={12} sm={selectedButton === "Map" ? 12 : 4} lg={4} xl={3}
                    sx={{
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "flex-end",
                        mt: 1
                    }}
                >
                    <FormControl fullWidth variant="outlined" sx={{ mb: 2 }}>
                        <InputLabel>Sort By</InputLabel>
                        <Select
                            label="Sort By"
                            value={sortOrder}
                            onChange={handleSortChange}
                        >
                            <MenuItem value="most-relevant">Most Relevant</MenuItem>
                            <MenuItem value="highest">Price: Highest to Lowest</MenuItem>
                            <MenuItem value="lowest">Price: Lowest to Highest</MenuItem>
                            <MenuItem value="newest">Date Added: Newest First</MenuItem>
                            <MenuItem value="oldest">Date Added: Oldest First</MenuItem>
                        </Select>
                    </FormControl>
                </Grid>

                {properties.map((property) => (
                    <Grid item key={property.id} xs={12} sm={listSizeSm} md={listSizeMd} lg={listSize}>
                        <PropertyCard property={property} />
                    </Grid>
                ))}
            </Grid>
        </Box>
    );
}
