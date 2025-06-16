import React from 'react';
import { Grid, Box, Typography, Divider, Button } from '@mui/material';

function PropertyDetails({ property }) {
    if (!property) return null;  // Return nothing if property is null

    // Construct the full address
    const fullAddress = `${property.address}${property.address2 ? `, ${property.address2}` : ''}`;
    const fullAddress2 = `${property.city}, ${property.state} ${property.zip}`;

    // Function to format price correctly (handles already formatted strings)
    const formatPrice = (value) => {
        if (!value || value === "0" || value === 0) return "TBD"; // Handle undefined, empty, or zero values
        const num = Number(String(value).replace(/,/g, "")); // Remove commas and convert to number
        if (isNaN(num) || num === 0) return "TBD"; // Handle invalid numbers and ensure 0 is "TBD"
        return `$${num.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    };

    function capitalizeFirstLetter(str) {
        if (!str) return '';  // Return empty string if input is null or empty
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    const activeStatus = property.status === "active";

    const detailFontSizeTitle = {
        xs: "5vw",
        sm: '2vw',
        md: '1.25vw',
        lg: "1vw",
        xl: ".8vw",
    }

    const detailFontSize = {
        xs: "7vw",
        sm: '3vw',
        md: '2vw',
        lg: "1.5vw",
        xl: "1.2vw",
    }

    // Converts fractions like "3/2" to decimals like 1.5
    const convertFractionToDecimal = (value) => {
        if (typeof value === 'string' && value.includes('/')) {
            const [numerator, denominator] = value.split('/').map(Number);
            return (numerator / denominator).toFixed(1).replace('.0', '');
        }
        return Number(value).toFixed(1).replace('.0', '');  // Handles normal numbers
    };

    return (
        <Box
            sx={{
                position: 'relative',
                backgroundColor: "#f8f8f8",
                borderRadius: "10px",
                p: 3,
                mb: 3,
                boxShadow: 2,
                height: "100%",
                display: "flex",
                flexDirection: "column",
                justifyContent: "space-between"  // Ensure content is spaced evenly
            }}
        >
            <Box
                sx={{
                    position: {
                        xs: 'relative',  // Center horizontally on xs screens
                        sm: 'absolute',   // Keep absolute positioning on larger screens
                    },
                    top: {
                        xs: 'auto',       // Disable top positioning on xs
                        sm: 16,           // Maintain top position on larger screens
                    },
                    right: {
                        xs: 'auto',       // Disable right positioning on xs
                        sm: 16,           // Maintain right position on larger screens
                    },
                    margin: {
                        xs: '0 auto',     // Center horizontally on xs
                    },
                    backgroundColor: activeStatus ? "#4CAF50" : "#F44336",
                    color: "white",
                    borderRadius: "25px",
                    px: 2,
                    py: 0,
                    fontSize: {
                        xs: "4vw",
                        sm: "2vw",
                        md: "1.5vw",
                        lg: "1vw",
                        xl: "1vw",
                    },
                    fontWeight: 600,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: "10px",
                    boxShadow: 1,
                }}
            >
                <Box
                    sx={{
                        width: {
                            xs: "2.5vw",
                            sm: "1.5vw",
                            md: "1vw",
                            lg: ".5vw",
                        },
                        height: {
                            xs: "2.5vw",
                            sm: "1.5vw",
                            md: "1vw",
                            lg: ".5vw",
                        },
                        backgroundColor: "white",
                        borderRadius: "50%",
                    }}
                />
                {activeStatus ? "Active" : "Sold"}
            </Box>


            <Grid
                container
                spacing={{
                    xs: 2,
                    sm: 1,
                    md: 2,
                    xl: 3
                }}
                sx={{ mt: 0 }}
            >
                <Grid item xs={12}
                    sx={{
                        mb: {
                            xs: 0,
                            xl: 2
                        }
                    }}
                >
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: {
                                xs: "8vw",
                                sm: '6vw',
                                md: '3vw',
                                lg: "2.5vw",
                                xl: "2.25vw",
                            },
                            fontWeight: 700,
                            fontFamily: "Poppins",
                        }}
                    >
                        {fullAddress}
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: {
                                xs: "6vw",
                                sm: '4vw',
                                md: '2.2vw',
                                lg: "2vw",
                                xl: "1.5vw",
                            },
                            fontWeight: 500,
                            fontFamily: "Poppins",
                            color: "gray",
                            mt: -2,
                        }}
                    >
                        {fullAddress2}
                    </Typography>
                </Grid>

                <Grid item xs={12}>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: {
                                xs: "7vw",
                                sm: '4vw',
                                md: '2.5vw',
                                lg: "2vw",
                                xl: "1.5vw",
                            },
                            fontWeight: 700,
                            fontFamily: "Montserrat",
                            textDecoration: "underline",
                        }}
                    >
                        Property Details
                    </Typography>
                </Grid>

                <Grid item xs={12} sm={6} md={4} lg={3}>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSizeTitle,
                            fontWeight: 400,
                            fontFamily: "Montserrat",
                            color: "gray",
                            lineHeight: 1,
                        }}
                    >
                        Property Type:
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSize,
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                        }}
                    >
                        {property.type}
                    </Typography>
                </Grid>

                <Grid item xs={12} sm={6} md={4} lg={3}>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSizeTitle,
                            fontWeight: 400,
                            fontFamily: "Montserrat",
                            color: "gray",
                            lineHeight: 1,
                        }}
                    >
                        {property.salemethod === "rental" ? "Monthly Rent" : "Price"}:
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSize,
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                        }}
                    >
                        {property.salemethod === "rental" ? `${formatPrice(property.rentprice)}` : `${formatPrice(property.price)}`}
                    </Typography>
                </Grid>

                <Grid item xs={12} sm={6} md={4} lg={3}>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSizeTitle,
                            fontWeight: 400,
                            fontFamily: "Montserrat",
                            color: "gray",
                            lineHeight: 1,
                        }}
                    >
                        Sale Type:
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSize,
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                        }}
                    >
                        {capitalizeFirstLetter(property.salemethod)}
                    </Typography>
                </Grid>

                <Grid item xs={12} sm={6} md={4} lg={3}>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSizeTitle,
                            fontWeight: 400,
                            fontFamily: "Montserrat",
                            color: "gray",
                            lineHeight: 1,
                        }}
                    >
                        Negotiable:
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSize,
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                        }}
                    >
                        {capitalizeFirstLetter(property.negotiable)}
                    </Typography>
                </Grid>

                <Grid item xs={12} sm={6} md={4} lg={3}>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSizeTitle,
                            fontWeight: 400,
                            fontFamily: "Montserrat",
                            color: "gray",
                            lineHeight: 1,
                        }}
                    >
                        Bedrooms:
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSize,
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                        }}
                    >
                        {convertFractionToDecimal(property.bedrooms)} Beds
                    </Typography>
                </Grid>

                <Grid item xs={12} sm={6} md={4} lg={3}>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSizeTitle,
                            fontWeight: 400,
                            fontFamily: "Montserrat",
                            color: "gray",
                            lineHeight: 1,
                        }}
                    >

                        Bathrooms:
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSize,
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                            //mb: 2,
                        }}
                    >
                        {convertFractionToDecimal(property.bathrooms)} Baths
                    </Typography>
                </Grid>

                <Grid item xs={12} sm={6} md={4} lg={3}>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSizeTitle,
                            fontWeight: 400,
                            fontFamily: "Montserrat",
                            color: "gray",
                            lineHeight: 1,
                        }}
                    >

                        Lot Size:
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSize,
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                            //mb: 2,
                        }}
                    >
                        {property.size ? property.size : "--"} sqrt
                    </Typography>
                </Grid>

                <Grid item xs={12} sm={6} md={4} lg={3}>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSizeTitle,
                            fontWeight: 400,
                            fontFamily: "Montserrat",
                            color: "gray",
                            lineHeight: 1,
                        }}
                    >

                        Date Posted:
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSize,
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                            //mb: 2,
                        }}
                    >
                        {property.date}
                    </Typography>
                </Grid>

                <Grid item xs={12} >
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSizeTitle,
                            fontWeight: 400,
                            fontFamily: "Montserrat",
                            color: "gray",
                            lineHeight: 1,
                        }}
                    >

                        Property Description:
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: { xs: "center", sm: "left" },
                            fontSize: detailFontSize,
                            fontWeight: 600,
                            fontFamily: "Montserrat",
                            //mb: 2,
                            lineHeight: {
                                xs: 1,
                                sm: "normal",
                            }
                        }}
                    >
                        {property.description}
                    </Typography>
                </Grid>


            </Grid>

            {property.salemethod === "rental" && (
                <Button
                    variant="contained"
                    href="/rental-application"
                    target="_blank"
                    color="info"
                    //size="large"
                    fullWidth
                    sx={{
                        fontSize: {
                            xs: "4vw",
                            sm: '2vw',
                            md: '1vw',
                            lg: "1vw",
                            xl: "1vw",
                        },
                        fontWeight: 600,
                        fontFamily: "Montserrat",
                        '&:hover': {
                            backgroundColor: "green",
                            color: "white",
                        },
                        mt: {xs: 2, sm: 0}
                    }}
                >
                    Apply to Rent
                </Button>
            )}
        </Box>
    );
}

export default PropertyDetails;
