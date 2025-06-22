'use client';
import React from 'react';
import {
    Box,
    Grid,
    Typography,
    Button,
    TextField,
    RadioGroup,
    FormControlLabel,
    Radio,
} from '@mui/material';
import { ArrowForward } from '@mui/icons-material';

export default function ResponseSection({ 
    verdict = "Unknown", 
    reason = "No reason provided",
}) {
    console.log("Rendering ResponseSection with verdict:", verdict);
    console.log("Rendering ResponseSection with reason:", reason);
    return (
        <Box
            sx={{
                position: 'relative',
                zIndex: 1,
                width: '40%',
                height: {
                    xs: '100%',
                    sm: '100%',
                    md: '100%',
                    lg: '100%',
                    xl: '20vh',
                },

            }}
        >
            <Grid
                container
                spacing={2}
                sx={{
                    /*position: 'absolute',
                    top: '50%',
                    left: '50%',
                    transform: 'translate(-50%, -50%)',*/
                    zIndex: 2,
                    backgroundColor: '#f4f6f6',
                    borderRadius: "20px",
                    boxShadow: 10,
                    p: 3,
                }}
            >
                <Grid size={12}>
                    <Typography
                        sx={{
                            textAlign: "left",
                            color: verdict === "Correct" ? "green" : "#f4f6f6",
                            lineHeight: 1,
                            fontWeight: 600,
                            fontFamily: 'Poppins',
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '1.25rem',
                            },
                        }}
                    >
                        {verdict}
                    </Typography>
                </Grid>

                <Grid size={12}>
                    <Typography
                        sx={{
                            textAlign: "left",
                            color: "black",
                            lineHeight: 1,
                            fontWeight: 600,
                            fontFamily: 'Poppins',
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '1rem',
                            },
                        }}
                    >
                        {reason}
                    </Typography>
                </Grid>
            </Grid>
        </Box >
    );
}
