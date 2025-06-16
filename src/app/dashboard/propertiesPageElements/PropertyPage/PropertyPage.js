import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import { Grid, Snackbar, Alert } from '@mui/material';

import config from '../../config.js';

// Custom Components
import PropertyHeroGrid from './PropertyHero/PropertyHeroGrid';
import PropertyHeroGridSkeleton from './PropertyHero/PropertyHeroSkeleton';
import PropertyDetails from './PropertyDetails/PropertyDetails.js';
import PropertyMap from './PropertyMap.js/PropertyMap.js';
import PropertyDetailsSkeleton from './PropertyDetails/PropertyDetailsSkeleton.js';

// API Configuration
const environment = process.env.NODE_ENV || 'development';
const api = axios.create({
    baseURL: config[environment].apiUrl.replace('/api', ''),
});

function PropertyPage({ appBarHeight }) {
    const { address } = useParams();  // Get the tag from the URL
    const propertyTag = address.toLowerCase();

    const [properties, setProperties] = useState([]);
    const [loadingProperties, setLoadingProperties] = useState(true);
    const [selectedProperty, setSelectedProperty] = useState(null);
    const [error, setError] = useState(null);
    const [photoUrls, setPhotoUrls] = useState([]);
    const [snackbarOpen, setSnackbarOpen] = useState(false);

    const formatPriceForSorting = (value) => {
        if (!value || value === "0" || value === 0) return 0;
        return Number(String(value).replace(/,/g, "")) || 0;
    };

    const generatePropertyTag = (property) => {
        return property.address
            .replace(/ /g, "-")
            .replace(/[^a-zA-Z0-9-]/g, "")
            .toLowerCase();
    };

    // Fetch properties and find the matching one
    useEffect(() => {
        setLoadingProperties(true);
        const fetchProperties = async () => {
            try {
                const response = await api.get("/api/properties");

                let formattedProperties = response.data.map((property, index) => ({
                    ...property,
                    tag: generatePropertyTag(property),
                    price: formatPriceForSorting(property.price),
                    photoUrl: ""
                }));

                const photoUrls = await Promise.all(
                    formattedProperties.map(async (property) => {
                        try {
                            const response = await api.post('/api/getFrontPhoto', {
                                address: property.address,
                            });
                            return response.data.photoUrl || "";
                        } catch (error) {
                            console.error(`Error fetching photo for ${property.address}:`, error);
                            return "";
                        }
                    })
                );

                formattedProperties = formattedProperties.map((property, index) => ({
                    ...property,
                    photoUrl: photoUrls[index],
                }));

                setProperties(formattedProperties);

                const matchedProperty = formattedProperties.find(p => p.tag === propertyTag);
                if (matchedProperty) {
                    setSelectedProperty(matchedProperty);
                   
                    const response = await api.post('/api/getAllPhotos', {
                        address: matchedProperty.address,
                    });
                    setPhotoUrls([matchedProperty.photoUrl, ...response.data.otherPhotos]);
                    setError(null);  // Clear any previous error
                } else {
                    setError("Property not found.");
                    setSnackbarOpen(true);  // Open snackbar if error
                }

                setLoadingProperties(false);
            } catch (error) {
                console.error("Property Fetch Error:", error);
                setError("Failed to load properties.");
                setSnackbarOpen(true);  // Open snackbar if error
                setLoadingProperties(true);  // Keep loading true if error
            }
        };

        fetchProperties();
    }, [propertyTag]);  // Run when propertyTag changes

    const handleCloseSnackbar = () => {
        setSnackbarOpen(false);
    };

    return (
        <>
            <Grid
                container
                //columnSpacing={2}
                sx={{
                    mt: `${appBarHeight}px`,
                    width: "100%",
                    height: "100%",
                    p: 2,
                }}
            >
                {loadingProperties ? (
                    <>
                        <PropertyHeroGridSkeleton />
                        <PropertyDetailsSkeleton />
                    </>
                ) : (
                    <>
                        <PropertyHeroGrid
                            properties={properties}
                            selectedProperty={selectedProperty}
                            setSelectedProperty={setSelectedProperty}
                            photoUrls={photoUrls}
                            setPhotoUrls={setPhotoUrls}
                        />

                        {/* Property Details Section */}
                        <Grid item
                            xs={12}
                            md={6}
                            sx={{
                                mt: 2,
                                pr: { xs: 0, sm: 1, md: 2 }
                            }}
                        >
                            <PropertyDetails property={selectedProperty} />
                        </Grid>

                        {/* Map Section */}
                        <Grid item
                            xs={12}
                            md={6}
                            sx={{ mt: 2 }}
                        >
                            <PropertyMap property={selectedProperty} />
                        </Grid>
                    </>
                )}
            </Grid>

            <Snackbar
                open={snackbarOpen}
                autoHideDuration={8000}
                onClose={handleCloseSnackbar}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
            >
                <Alert
                    onClose={handleCloseSnackbar}
                    severity="error"
                    sx={{ width: '100%' }}
                >
                    Property does not exist.
                </Alert>
            </Snackbar>
        </>
    );
}

export default PropertyPage;
