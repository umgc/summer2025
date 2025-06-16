"use client";

import React, { useState, useEffect, useRef } from "react";
import mapboxgl from "mapbox-gl";
import axios from "axios";
import { useLocation } from "react-router-dom";
import "mapbox-gl/dist/mapbox-gl.css";

import { Box, Skeleton } from "@mui/material";

// API Configuration
import config from "../../config";
const environment = process.env.NODE_ENV || "development";
const api = axios.create({
  baseURL: config[environment].apiUrl.replace("/api", ""),
});

export default function MBPropertyMap({ properties }) {
  const location = useLocation();
  const mapContainer = useRef(null);
  const map = useRef(null);

  const BALTIMORE_COORDS = { lng: -76.6122, lat: 39.2904 };
  const DEFAULT_ZOOM = 12;

  const [mapKey, setMapKey] = useState("");
  const [geoCodedProperties, setGeoCodedProperties] = useState([]);
  const [loadingMap, setLoadingMap] = useState(true); // Map loading state

  useEffect(() => {
    setLoadingMap(true);
    setGeoCodedProperties([]);
    
    const fetchData = async () => {
      try {
        // Fetch properties and Mapbox token
        const propertyResponse = await api.get("/api/properties");

        let properties = propertyResponse.data;
        if (location.pathname === "/sold-properties") {  //Filter for Sold properties
          properties = properties.filter((obj) => obj.status === "sold");
        } else if (location.pathname === "/developments") {  //Filter for Development properties
          properties = properties.filter((obj) => obj.salemethod === "development");
        } else {
          // Exclude Sold and Development properties for other paths
          properties = properties.filter((obj) => obj.status !== "sold" && obj.salemethod !== "development");
        }

        const tokenResponse = await api.get("/api/getMapBoxKey");
        const token = tokenResponse.data.apiKey;
        setMapKey(token);
        mapboxgl.accessToken = token;

        // Fetch Photo URLs
        const fetchPhotoUrls = async (property) => {
          try {
            const response = await api.post('/api/getFrontPhoto', {
              address: property.address,
            });
            return response.data.photoUrl;
          } catch (error) {
            console.error(`Error fetching photo for ${property.address}:`, error);
            return null; // Return null if there's an error
          }
        };

        // Process each property: geocode & fetch photo URL
        const geoCoded = await Promise.all(
          properties.map(async (property) => {
            const address = `${property.address}, ${property.city}, ${property.state} ${property.zip}`;
            const coords = await geocodeAddress(address, token);
            const photoUrl = await fetchPhotoUrls(property);

            return {
              ...property,
              latitude: coords?.lat,
              longitude: coords?.lng,
              photoUrl: photoUrl || "https://via.placeholder.com/300", // Use placeholder if no photo
            };
          })
        );

        setGeoCodedProperties(geoCoded.filter((p) => p.latitude && p.longitude));
        setLoadingMap(false);
      } catch (error) {
        console.error("API Fetch Error:", error);
        setLoadingMap(false); // Set loading state to false if there's an error
      }
    };

    fetchData();
  }, [location.pathname]);

  const geocodeAddress = async (address, token) => {
    try {
      const response = await axios.get(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(
          address
        )}.json?access_token=${token}`
      );

      if (response.data.features.length === 0) {
        console.warn(`No coordinates found for address: ${address}`);
        return null;
      }

      const [lng, lat] = response.data.features[0].center;
      return { lat, lng };
    } catch (error) {
      console.error(`Geocoding Error for ${address}:`, error);
      return null;
    }
  };

  useEffect(() => {
    if (!mapKey || map.current) return;

    map.current = new mapboxgl.Map({
      container: mapContainer.current,
      style: "mapbox://styles/mapbox/streets-v11",
      center: [BALTIMORE_COORDS.lng, BALTIMORE_COORDS.lat],
      zoom: DEFAULT_ZOOM,
    });

    // Map load event to update loading state
    map.current.on("load", () => setLoadingMap(false));

    return () => map.current?.remove();
  }, [mapKey]);

  useEffect(() => {
    if (!map.current || geoCodedProperties.length === 0) return;

    const bounds = new mapboxgl.LngLatBounds();
    geoCodedProperties.forEach((property) => bounds.extend([property.longitude, property.latitude]));

    if (geoCodedProperties.length === 1) {
      map.current.flyTo({
        center: [geoCodedProperties[0].longitude, geoCodedProperties[0].latitude],
        zoom: 14,
      });
    } else {
      map.current.fitBounds(bounds, { padding: 50, maxZoom: 14 });
    }

    geoCodedProperties.forEach((property) => {
      const popupContent = `
          <div style="max-width: 250px; font-family: Arial, sans-serif;">
              <img 
                src="${property.photoUrl}" 
                alt="Property Image" 
                style="width: 100%; 
                height: auto; 
                border-radius: 8px;"
              />
              <h3 style="margin: 5px 0; font-size: 16px; font-weight: bold; text-align: center;">${property.address}</h3>
             
              <p style="margin: 5px 0; font-size: 14px; text-align: center;">
                  <strong>${property.bedrooms}</strong> Beds | <strong>${property.bathrooms}</strong> Baths
              </p>
             
              <p style="margin: 5px 0; font-size: 14px; text-align: center; color: #007bff;">
                  ${property.salemethod.toUpperCase()} - $${Number(property.price).toLocaleString()}
              </p>
          </div>
      `;

      new mapboxgl.Marker()
        .setLngLat([property.longitude, property.latitude])
        .setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(popupContent))
        .addTo(map.current);
    });

  }, [geoCodedProperties]);

  return (
    <Box
      ref={mapContainer}
      sx={{
        width: "97%",
        height: "100%",
        mx: 2,
        borderRadius: "25px",
        position: "relative",
      }}
    >
      {loadingMap && (
        <Skeleton
          variant="rectangular"
          sx={{
            width: "100%",
            height: "100%",
            //position: "absolute",
            top: 0,
            left: 0,
            zIndex: 1,
            borderRadius: "25px",
          }}
        />
      )}
    </Box>
  );
}
