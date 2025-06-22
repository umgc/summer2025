import { FileUpload, PlayArrow } from '@mui/icons-material';
import {
    Skeleton,
    Box,
    Button,
    Typography,
} from '@mui/material';
import React from 'react';

export default function ErrorRender({ subHeight }) {

    return (
        <Box sx={{ position: 'relative', zIndex: 1, width: '100%', height: '100%' }}>
            {/* Start Simulation Button */}
            <Box
                sx={{
                    position: 'absolute',
                    top: '50%',
                    left: '50%',
                    transform: 'translate(-50%, -50%)',
                    zIndex: 2,
                    display: 'flex',
                    flexDirection: 'column',
                    gap: 1,
                }}
            >
                <Typography
                    sx={{
                        textAlign: "center",
                        color: "error.main",
                        lineHeight: 1,
                        fontWeight: 600,
                        fontFamily: 'Poppins',
                        fontSize: {
                            xs: '1.1vw',
                            sm: '1.2vw',
                            md: '1.3vw',
                            lg: '1.4vw',
                            xl: '3rem',
                        },
                    }}
                >
                    Error: Simulation Error
                </Typography>
                <Typography
                    sx={{
                        textAlign: "center",
                        color: "black",
                        lineHeight: 1,
                        fontWeight: 600,
                        fontFamily: 'Poppins',
                        fontSize: {
                            xs: '1.1vw',
                            sm: '1.2vw',
                            md: '1.3vw',
                            lg: '1.4vw',
                            xl: '2rem',
                        },
                    }}
                >
                    Please Check Your Scenario/Node Format.
                </Typography>
            </Box>

            {/* Background Skeleton */}
            <Skeleton
                variant="rectangular"
                animation="wave"
                sx={{
                    width: '100%',
                    height: subHeight || '100%',
                }}
            />
        </Box>
    );
}
