import React, { useState, useEffect } from 'react';

import {
    Grid,
    Box,
    Button,
    useTheme,
    useMediaQuery,
} from '@mui/material';
import { PhotoCamera } from '@mui/icons-material';
import PhotoDialog from './PhotoDialog.js';  // Import the new dialog component

function PropertyHeroGrid({
    selectedProperty,
    setSelectedProperty,
    photoUrls,
    setPhotoUrls,
    properties,
}) {

    const [openDialog, setOpenDialog] = useState(false);

    const buttonFontSize = {
        xs: "3vw",
        sm: "1.75vw",
        md: "1.2vw",
        lg: "1vw",
        xl: ".8vw",
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
                return 5; // Large screens
            case isLg:
                return 5; // Large screens
            case isMd:
                return 5; // Medium screens
            case isSm:
                return 3; // Small screens
            case isXs:
                return 2; // Extra small screens
            default:
                return 5; // Fallback size
        }
    })();

    return (
        <>
            <Grid
                item
                xs={12}
                md={6}
                sx={{
                    display: "flex",
                    height: "100%",
                    overflow: "hidden",
                    pr: { xs: 0, md: 2 },
                    mb: { xs: 1, sm: 2, md: 0 },
                }}
            >
                <Box
                    component="img"
                    src={selectedProperty.photoUrl}
                    alt="Front Photo"
                    onClick={() => setOpenDialog(true)}  // Make front photo clickable
                    sx={{
                        width: {
                            xs: "100%",
                            md: "50vw",
                        },
                        height: "100%",
                        maxHeight: {
                            xs: "75vw",
                            sm: "51vw",
                            md: "51vw",
                            lg: "51vh",
                        },
                        objectFit: "cover",
                        borderRadius: {xs: "25px", sm: "10px"},
                        cursor: "pointer",  // Indicate clickable
                        transition: "transform 0.3s",
                        "&:hover": {
                            transform: "scale(1.02)",
                        },
                    }}
                />
            </Grid>

            <Grid
                item
                xs={12}
                md={6}
                container
            //spacing={{xs: 1, sm: 2}}
            >
                {photoUrls.slice(1, photoMax).map((url, index) => (
                    <Grid item xs={12} sm={6} key={index}
                        sx={{
                            position: "relative",
                            pr: isXs ? 0 : (index === 0 || index === 2 ? 2 : 0),
                            pb: isMdDown ? 0 : (index === 0 || index === 1 ? 2 : 0),
                        }}
                    >
                        <Box
                            component="img"
                            src={url}
                            alt={`Photo ${index + 1}`}
                            onClick={() => setOpenDialog(true)}  // Make photos clickable
                            sx={{
                                width: "100%",
                                height: {
                                    xs: "50vw",
                                    sm: "25vw",
                                    md: "25vw",
                                    lg: "25vh",
                                },
                                objectFit: "cover",
                                borderRadius: "10px",
                                cursor: "pointer",  // Indicate clickable
                                transition: "transform 0.3s",
                                "&:hover": {
                                    transform: "scale(1.02)",
                                },
                            }}
                        />
                        {index === buttonIndex && (
                            <Button
                                onClick={() => setOpenDialog(true)}
                                variant="contained"
                                sx={{
                                    position: "absolute",
                                    bottom: 16,
                                    right: 16,
                                    backgroundColor: "#ad0800",
                                    color: "white",
                                    borderRadius: "8px",
                                    padding: {
                                        xs: 1,
                                        xl: 1,
                                    },
                                    fontSize: buttonFontSize,   // Bigger text
                                    fontWeight: "bold",     // Bold text
                                    display: "flex",        // Ensure flex layout for icon and text
                                    alignItems: "center",
                                    "&:hover": {
                                        backgroundColor: "#f1dfbb",
                                        color: "#ad0800"
                                    },
                                }}
                            >
                                <PhotoCamera
                                    sx={{
                                        fontSize: buttonFontSize,   // Bigger icon size
                                        marginRight: "10px" // Space between icon and text
                                    }}
                                />
                                See all {photoUrls.length} photos
                            </Button>
                        )}
                    </Grid>
                ))}
            </Grid>

            {/* Dialog for showing all photos */}
            <PhotoDialog
                open={openDialog}
                onClose={() => setOpenDialog(false)}
                photoUrls={photoUrls}
            />
        </>
    );
}

export default PropertyHeroGrid;
