import React from 'react';
import { Dialog, DialogContent, Typography, Grid, Box, IconButton } from '@mui/material';
import Zoom from 'react-medium-image-zoom';
import CloseIcon from '@mui/icons-material/Close';
import 'react-medium-image-zoom/dist/styles.css';

function PhotoDialog({ open, onClose, photoUrls }) {

    const photoHeight12 = {
        xs: "80vw",
        sm: "60vw",
        md: "50vw",
        lg: "40vw",
        xl: "30vw",
    }

    const photoHeight6 = {
        xs: "80vw",
        sm: "35vw",
        md: "30vw",
        lg: "25vw",
        xl: "20vw",
    }


    return (
        <Dialog
            open={open}
            onClose={onClose}
            maxWidth="lg"
            fullWidth
            sx={{
                '& .MuiDialog-paper': {
                    position: 'relative',
                    overflow: 'hidden', // Prevents double scrollbar
                },
            }}
        >
            {/* Close Button */}
            <IconButton
                onClick={onClose}
                sx={{
                    position: 'absolute',
                    top: 10,
                    right: 25,
                    backgroundColor: '#ad0800',
                    color: '#f1dfbb',
                    zIndex: 10,
                    '&:hover': {
                        backgroundColor: '#f1dfbb',
                        color: '#ad0800',
                    },
                }}
            >
                <CloseIcon fontSize="large" />
            </IconButton>

            <DialogContent sx={{ overflow: 'auto', paddingTop: 6 }}>
                <Grid container spacing={2}>
                    {photoUrls.map((url, index) => {
                        // Determine the grid size based on the pattern
                        const gridSize = index % 3 === 0 ? 12 : 6;

                        return (
                            <Grid item xs={12} sm={gridSize} key={index}>
                                <Zoom>
                                    <Box
                                        component="img"
                                        src={url}
                                        alt={`Photo ${index + 1}`}
                                        sx={{
                                            width: "100%",
                                            height: gridSize === 12 ? photoHeight12 : photoHeight6,
                                            objectFit: "cover",
                                            borderRadius: "5px",
                                            cursor: "pointer",
                                            transition: "transform 0.3s",
                                            "&:hover": {
                                                transform: "scale(1.02)",
                                            },
                                        }}
                                    />
                                </Zoom>
                            </Grid>
                        );
                    })}
                </Grid>
            </DialogContent>
        </Dialog>
    );
}

export default PhotoDialog;
