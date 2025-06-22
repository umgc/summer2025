import { FileUpload, PlayArrow } from '@mui/icons-material';
import { Skeleton, Box, Button } from '@mui/material';
import React from 'react';

export default function DefaultRender({ project, onStart, onLoad, subHeight }) {
    console.log("DefaultRender project:", project);
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
                }}
            >
                {!project || project === undefined || Object.keys(project).length === 0 ? (
                    <Button
                        variant="contained"
                        color="primary"
                        onClick={onLoad}
                        sx={{
                            px: 4,
                            py: 1.5,
                            fontSize: '1rem',
                            '&:hover': {
                                backgroundColor: 'black',
                                boxShadow: 10,
                            }
                        }}
                        endIcon={<FileUpload />}
                    >
                        Load Simulation
                    </Button>
                ) : (
                    <Button
                        variant="contained"
                        color="success"
                        onClick={onStart}
                        sx={{
                            px: 4,
                            py: 1.5,
                            fontSize: '1rem',
                            '&:hover': {
                                backgroundColor: 'black',
                                boxShadow: 10,
                            }
                        }}
                        endIcon={<PlayArrow />}
                    >
                        Start Simulation
                    </Button>
                )}
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
