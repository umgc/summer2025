import React from 'react';
import { Grid, Box, Skeleton, Button } from '@mui/material';

function PropertyDetailsSkeleton() {
    return (
        <Grid container spacing={2} sx={{mx: 2, my: 1}}>
            {/* Property Details Skeleton */}
            <Grid item xs={12} md={6}>
                <Box
                    sx={{
                        backgroundColor: "#f8f8f8",
                        borderRadius: "10px",
                        p: 3,
                        mb: 3,
                        boxShadow: 2,
                        height: "100%",
                        display: "flex",
                        flexDirection: "column",
                    }}
                >
                    {/* Status Badge Skeleton */}
                    <Skeleton
                        variant="rectangular"
                        sx={{
                            position: 'absolute',
                            top: 16,
                            right: 16,
                            width: "120px",
                            height: "30px",
                            borderRadius: "20px",
                        }}
                    />

                    {/* Address Skeleton */}
                    <Skeleton variant="text" sx={{ fontSize: '2.5vw', mb: 1, width: "80%" }} />
                    <Skeleton variant="text" sx={{ fontSize: '1.5vw', mb: 2, width: "60%" }} />

                    {/* Property Details Header Skeleton */}
                    <Skeleton variant="text" sx={{ fontSize: '1.5vw', mb: 2, width: "50%" }} />

                    {/* Property Info Skeleton */}
                    {Array.from({ length: 6 }).map((_, index) => (
                        <Box key={index} sx={{ mb: 2 }}>
                            <Skeleton variant="text" sx={{ fontSize: '.8vw', width: "40%" }} />
                            <Skeleton variant="text" sx={{ fontSize: '1.2vw', width: "60%" }} />
                        </Box>
                    ))}

                    {/* Apply to Rent Button Skeleton */}
                    <Skeleton
                        variant="rectangular"
                        sx={{
                            mt: "auto",
                            alignSelf: "center",
                            width: "80%",
                            height: "40px",
                            borderRadius: "5px",
                            mb: 2,
                        }}
                    />
                </Box>
            </Grid>

            {/* Map Skeleton */}
            <Grid item xs={12} md={6}>
                <Skeleton
                    variant="rectangular"
                    sx={{
                        width: "100%",
                        height: "100%",
                        borderRadius: "10px",
                        minHeight: "500px",
                    }}
                />
            </Grid>
        </Grid>
    );
}

export default PropertyDetailsSkeleton;
