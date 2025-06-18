'use client';
import React, { useState, useEffect } from 'react';
import {
    Box,
    Typography,
    Select,
    MenuItem,
    FormControl,
    InputLabel,
} from '@mui/material';
import { TimeClock } from '@mui/x-date-pickers/TimeClock';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';



export default function ClockDisplay({ dayjsTime }) {


    return (
        <LocalizationProvider dateAdapter={AdapterDayjs}>
            <Box
                sx={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'flex-start',
                    height: '100%',
                    width: '100%',
                    //overflow: 'hidden',
                    //transform: 'scale(1.3)', // increase to make it bigger (e.g., 1.5 for 150%)
                    //transformOrigin: 'center center', // keep it aligned nicely
                }}
            >
                {/* Clock */}
                <TimeClock
                    value={dayjsTime}
                    readOnly
                    sx={{
                        mt: 2,
                        //height: "50rem",
                        '& .MuiClock-clock': {
                            //transform: 'scale(1.2)', // optional for making it bigger
                        },
                    }}
                />

                
            </Box>
        </LocalizationProvider>
    );
}
