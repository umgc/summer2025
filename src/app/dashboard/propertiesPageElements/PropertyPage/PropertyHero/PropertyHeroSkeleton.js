import React from 'react';
import { Grid, Box, Skeleton, Button, useTheme, useMediaQuery } from '@mui/material';
import { PhotoCamera } from '@mui/icons-material';

function PropertyHeroGridSkeleton() {

    const buttonFontSize = {
        xs: "3vw",
        sm: "1.75vw",
        md: "1.2vw",
        lg: "1vw",
        xl: "1vw",
    }

    const theme = useTheme();
    const isXl = useMediaQuery(theme.breakpoints.up("xl"));
    const isLg = useMediaQuery(theme.breakpoints.only("lg"));
    const isMd = useMediaQuery(theme.breakpoints.only("md"));
    const isSm = useMediaQuery(theme.breakpoints.only("sm"));
    const isXs = useMediaQuery(theme.breakpoints.only("xs"));
    const isMdDown = useMediaQuery(theme.breakpoints.down("md"));

    //Get Button Dimensions
    const buttonIndex = (() => {
        switch (true) {
            case isXl:
                return 3; // Large screens
            case isLg:
                return 3; // Large screens
            case isMd:
                return 3; // Medium screens
            case isSm:
                return 1; // Small screens
            case isXs:
                return 0; // Extra small screens
            default:
                return 3; // Fallback size
        }
    })();

    const photoMax = (() => {
        switch (true) {
            case isXl:
                return 4; // Large screens
            case isLg:
                return 4; // Large screens
            case isMd:
                return 4; // Medium screens
            case isSm:
                return 1; // Small screens
            case isXs:
                return 1; // Extra small screens
            default:
                return 4; // Fallback size
        }
    })();

    return (

        <Grid container spacing={2} sx={{ mx: 2, my: 1 }}>
            {/* Main photo skeleton */}
            <Grid
                item
                xs={12}
                md={6}
                sx={{
                    display: "flex",
                    height: "100%",
                    overflow: "hidden"
                }}
            >
                <Skeleton
                    variant="rectangular"
                    sx={{
                        width: {
                            xs: "100%",
                            md: "50vw",
                        },
                        height: {
                            xs: "50vh",
                            sm: "50vh",
                            md: "100%",                            
                        },
                        maxHeight: "51vh",
                        borderRadius: "10px"
                    }}
                />
            </Grid>

            {!isMdDown && (
                <Grid item xs={12} md={6} container spacing={2}>
                    {Array.from({ length: photoMax }).map((_, index) => (
                        <Grid item xs={12} sm={6} key={index} sx={{ position: "relative" }}>
                            <Skeleton
                                variant="rectangular"
                                sx={{
                                    width: "100%",
                                    height: {
                                        xs: "50vw",
                                        sm: "25vw",
                                        md: "25vw",
                                        lg: "25vh",
                                    },
                                    borderRadius: "10px"
                                }}
                            />
                            {index === buttonIndex && (
                                <Skeleton
                                    variant="rectangular"
                                    sx={{
                                        position: "absolute",
                                        bottom: 16,
                                        right: 16,
                                        width: "150px",
                                        height: buttonFontSize,
                                        borderRadius: "5px"
                                    }}
                                />
                            )}
                        </Grid>
                    ))}
                </Grid>
            )}
        </Grid>
    );
}

export default PropertyHeroGridSkeleton;
