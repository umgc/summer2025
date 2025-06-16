import React, { useEffect, useRef, useState } from 'react';
import { Box } from '@mui/material';
import axios from 'axios';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import config from '../../../config.js';

// API Configuration
const environment = process.env.NODE_ENV || 'development';
const api = axios.create({
    baseURL: config[environment].apiUrl.replace('/api', ''),
});

function PropertyMap({ property }) {
    const mapContainer = useRef(null);
    const map = useRef(null);
    const [mapKey, setMapKey] = useState("");

    useEffect(() => {
        const fetchMapKey = async () => {
            try {
                const tokenResponse = await api.get("/api/getMapBoxKey");
                const token = tokenResponse.data.apiKey;
                setMapKey(token);
                mapboxgl.accessToken = token;
            } catch (error) {
                console.error("Error fetching Mapbox token:", error);
            }
        };

        fetchMapKey();
    }, []);

    // Map Initialization
    useEffect(() => {
        if (mapKey && property && mapContainer.current) {
            const geocodeAddress = async (address) => {
                try {
                    const response = await axios.get(
                        `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(
                            address
                        )}.json?access_token=${mapKey}`
                    );
                    if (response.data.features.length > 0) {
                        const [lng, lat] = response.data.features[0].center;
                        map.current = new mapboxgl.Map({
                            container: mapContainer.current,
                            style: 'mapbox://styles/mapbox/streets-v11',
                            center: [lng, lat],
                            zoom: 15,
                        });

                        new mapboxgl.Marker()
                            .setLngLat([lng, lat])
                            .addTo(map.current);
                    }
                } catch (error) {
                    console.error("Geocoding Error:", error);
                }
            };

            const fullAddress = `${property.address}, ${property.city}, ${property.state} ${property.zip}`;
            geocodeAddress(fullAddress);
        }

        // Clean up map when component unmounts
        return () => map.current?.remove();
    }, [mapKey, property]);

    return (
        <Box
            ref={mapContainer}
            sx={{
                width: "100%",
                height: {
                    xs: "60vh",
                    sm: "50vw",
                    md: "40vw",
                    lg: "40vw",
                },
                borderRadius: "10px",
                boxShadow: 2,
                overflow: "hidden"
            }}
        />
    );
}

export default PropertyMap;
