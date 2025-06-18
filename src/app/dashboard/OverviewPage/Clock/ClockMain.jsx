'use client';
import React, { useState, useEffect } from 'react';
import {
    Box,
    CssBaseline,
    Drawer,
    AppBar,
    Toolbar,
    Typography,
    List,
    ListItem,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    IconButton,
    Divider,
    Grid,
    Tooltip,
    Avatar,
    Button,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
} from '@mui/material';
import Link from 'next/link';
import Image from 'next/image';

import {
    Menu as MenuIcon,
    Home,
    TrendingUp,
    TrendingDown,
    People,
    School,
    Grading,
    Add,
    Update,
} from '@mui/icons-material';
import dayjs from 'dayjs';

//custom components
import AnimatedButton from "@/app/Buttons/AnimatedButton";
import ClockDisplay from './Clock';

// List of User's Projects
export default function ClockMain({
    user,
}) {
    const [now, setNow] = useState(new Date());
    const [timezone, setTimezone] = useState('America/New_York');
    const timeZones = [
        'America/New_York',
        'America/Chicago',
        'America/Denver',
        'America/Los_Angeles',
        'UTC',
        'Europe/London',
        'Asia/Tokyo',
    ];

    useEffect(() => {
        const interval = setInterval(() => {
            setNow(new Date());
        }, 1000);
        return () => clearInterval(interval);
    }, []);

    // Convert current local time to selected timezone
    const zonedTime = new Date(
        now.toLocaleString('en-US', { timeZone: timezone })
    );
    const dayjsTime = dayjs(zonedTime);

    return (
        <Grid size={2} sx={{ height: '100%', }}>
            <Box
                sx={{
                    backgroundColor: '#f8f9f9',
                    borderRadius: '20px',
                    border: '3px solid #e0e0e0',
                    p: 2,
                    height: '100%',
                    minHeight: '30vh',
                    //maxHeight: '30vh',
                    //overflow: 'hidden',
                    //overflowY: 'auto',
                }}
            >
                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'row',
                        justifyContent: 'space-between',
                        gap: 5,
                        alignItems: 'center',
                        mb: 3,
                    }}
                >
                    <Typography
                        sx={{
                            textAlign: "left",
                            color: "black",
                            //lineHeight: 1.2,
                            fontWeight: 500,
                            fontFamily: 'Poppins',
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '1.2vw',
                            },
                        }}
                    >
                        Time
                    </Typography>

                    {/* Time Zone Selector */}
                    <FormControl fullWidth size="small" sx={{ maxWidth: '200px' }}>
                        <InputLabel id="tz-label">Time Zone</InputLabel>
                        <Select
                            labelId="tz-label"
                            value={timezone}
                            label="Time Zone"
                            onChange={(e) => setTimezone(e.target.value)}
                            MenuProps={{ disablePortal: true }}
                        >

                            {timeZones.map((tz) => (
                                <MenuItem key={tz} value={tz}>
                                    {tz}
                                </MenuItem>
                            ))}
                        </Select>
                    </FormControl>
                </Box>

                <ClockDisplay dayjsTime={dayjsTime} />
            </Box>
        </Grid>
    );
}
