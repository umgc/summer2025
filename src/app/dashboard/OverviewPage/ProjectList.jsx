'use client';
import React from 'react';
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
    Grade,
} from '@mui/icons-material';


// List of User's Projects
export default function ProjectList({
    user,
}) {

    return (
        <Grid size={4}>
            <Box
                sx={{
                    backgroundColor: '#f8f9f9',
                    borderRadius: '20px',
                    border: '3px solid #e0e0e0',
                    p: 2,
                    height: '100%',
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
                    Recent Projects
                </Typography>

            </Box>
        </Grid>
    );
}
