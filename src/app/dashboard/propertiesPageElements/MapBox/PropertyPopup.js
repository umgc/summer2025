import React, { useState, useEffect } from 'react';
import {
    Box,
    Typography,
    Card,
    CardActionArea,
    CardMedia,
    CardContent,
    Grid,
    Button,
    Tooltip,
} from "@mui/material";

import {
    Bed,
    Bathtub,
    Place,
    ArrowOutward,
} from '@mui/icons-material';

export default function PropertyPopup({ property }) {

    const alignment = "center";
    const formatPrice =
        property.price && !isNaN(property.price)
            ? `$${Number(property.price).toLocaleString()}`
            : "Price TBD"; // Default text if price is missing


    return (
        <Card
            sx={{
                width: '100%',
                boxShadow: 3,
                borderRadius: "3%",
                backgroundColor: 'white', // Ensure transparency
                "&:hover": {
                    //border: `3px solid ${redColor}`,
                },

            }}
        >

            {/*<CardMedia
                component="img"
                image={property.photoUrl || "/images/house-coming-soon.jpg"}
                alt="Property Image"
                sx={{
                    height: {
                        xs: "15vw",
                        lg: "10vw",
                        xl: "50px",
                    },
                    width: "50px",
                }}
            />*/}

            <CardContent
                sx={{
                    backgroundColor: 'white', // Ensure CardContent is also transparent
                    //backdropFilter: "blur(0px)", // Ensures no overlay effect
                    color: "black", // Ensures text visibility
                }}
            >
                <Grid container spacing={0} sx={{ mx: 1, mt: 1 }}>
                    <Grid item xs={12}>
                        {/* Rental Price */}
                        {property.salemethod && property.salemethod.toLowerCase() === "rental" && (
                            <Typography
                                sx={{
                                    textAlign: alignment,
                                    fontSize: {
                                        xs: "1.5vw",
                                        sm: "2.25vw",
                                        md: "2vw",
                                        lg: "5vw",
                                    },
                                    fontWeight: 500,
                                    fontFamily: "Poppins",
                                    lineHeight: { xs: "1.05", md: "1" },
                                }}
                            >
                                {formatPrice}/month
                            </Typography>
                        )}

                        {/* Sale Price (Wholesale, Turnkey) */}
                        {["wholesale", "turnkey"].includes(property.salemethod?.toLowerCase()) && (
                            <Typography
                                sx={{
                                    textAlign: alignment,
                                    fontSize: {
                                        xs: "1.5vw",
                                        sm: "2.25vw",
                                        md: "2vw",
                                        lg: "1.5vw",
                                    },
                                    fontWeight: 500,
                                    fontFamily: "Poppins",
                                    lineHeight: { xs: "1.05", md: "1" },
                                }}
                            >
                                {formatPrice}
                            </Typography>
                        )}
                    </Grid>


                    <Grid item xs={2}>
                        <Typography
                            sx={{
                                textAlign: alignment,
                                fontSize: {
                                    xs: "1.5vw",
                                    sm: '2.25vw',
                                    md: '2vw',
                                    lg: "1vw"
                                },
                                fontWeight: 400,
                                fontFamily: "Montserrat",
                                //lineHeight: { xs: '1.05', md: '1' },
                                mt: 1,
                                display: "flex",
                                alignItems: "center"
                            }}
                        >
                            <Bed
                                sx={{
                                    fontSize: {
                                        xs: "1.5vw",
                                        sm: '2.25vw',
                                        md: '2vw',
                                        lg: "1.3vw"
                                    },
                                    verticalAlign: "middle",
                                    mr: 1
                                }}
                            />
                            {property.bedrooms}
                        </Typography>
                    </Grid>

                    <Grid item xs={2}>
                        <Typography
                            sx={{
                                textAlign: alignment,
                                fontSize: {
                                    xs: "1.5vw",
                                    sm: '2.25vw',
                                    md: '2vw',
                                    lg: "1vw"
                                },
                                fontWeight: 400,
                                fontFamily: "Montserrat",
                                //lineHeight: { xs: '1.05', md: '1' },
                                mt: 1,
                                display: "flex",
                                alignItems: "center"
                            }}
                        >
                            <Bathtub
                                sx={{
                                    fontSize: {
                                        xs: "1.5vw",
                                        sm: '2.25vw',
                                        md: '2vw',
                                        lg: "1.3vw"
                                    },
                                    verticalAlign: "middle",
                                    mr: 1
                                }}
                            />
                            {property.bedrooms}
                        </Typography>
                    </Grid>

                    <Grid item xs={9}>
                        {property.address && (
                            <>
                                {/* Address */}
                                <Typography
                                    sx={{
                                        textAlign: "left",
                                        fontSize: { xs: "1.5vw", sm: "2.25vw", md: "2vw", lg: ".8vw" },
                                        fontWeight: 400,
                                        fontFamily: "Montserrat",
                                        lineHeight: { xs: "1.05", md: "1" },
                                        mt: 1,
                                        ml: -0.5,
                                        display: "flex",
                                        alignItems: "center",
                                    }}
                                >
                                    <Place sx={{ fontSize: { xs: "1.5vw", sm: "2.25vw", md: "2vw", lg: "1vw" }, marginRight: "5px" }} />
                                    {property.address}
                                </Typography>

                                {/* City, State, Zip */}
                                <Typography
                                    sx={{
                                        textAlign: "left",
                                        fontSize: { xs: "1.25vw", sm: "2vw", md: "1.75vw", lg: ".8vw" },
                                        fontWeight: 400,
                                        fontFamily: "Montserrat",
                                        lineHeight: "1",
                                        mt: 0.5,
                                        ml: 3,
                                        display: "block",
                                    }}
                                >
                                    {property.city}, {property.state} {property.zip}
                                </Typography>
                            </>
                        )}
                    </Grid>

                </Grid>
            </CardContent>

        </Card>
    );
}
