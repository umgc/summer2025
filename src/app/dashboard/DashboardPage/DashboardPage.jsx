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
    Business,
    People,
    Settings,
    ArrowBackIos,
    ArrowForwardIos,
    Close,
} from '@mui/icons-material';

// Custom Components
import OverviewPage from '../OverviewPage/OverviewPage';

export default function DashboardPage({
    open, setOpen, user, selectedPage, 
}) {

    const openWidth = {
        xs: "10%",
        sm: "10%",
        md: "10%",
        lg: "10%",
        xl: "88%",
    }

    const closeWidth = {
        xs: "95%",
        sm: "95%",
        md: "95%",
        lg: "95%",
        xl: "95%",
    }

    const marginOpen = {
        xs: "10%",
        sm: "10%",
        md: "10%",
        lg: "10%",
        xl: "11.5%",
    }

    const marginClose = {
        xs: "6%",
        sm: "5%",
        md: "4%",
        lg: "4%",
        xl: "4.5%",
    }

    const MainHeight = {
        xs: "97%",
        sm: "97%",
        md: "97%",
        lg: "97%",
        xl: "89.5%",
    };

    return (
        <Box
            sx={{
                position: 'fixed',
                backgroundColor: '#f0f0f0',
                //border: '3px solid red',
                ml: open ? marginOpen : marginClose,
                mt: {
                    xs: "4%",
                    sm: "4%",
                    md: "4%",
                    lg: "6%",
                    xl: "4.5vw",
                },
                height: MainHeight,
                width: open ? openWidth : closeWidth,
                zIndex: 2000,
                overflow: 'hidden',
                transition: (theme) =>
                    theme.transitions.create(['margin', 'width'], {
                        easing: theme.transitions.easing.sharp,
                        duration: theme.transitions.duration.standard,
                    }),
                borderRadius: "20px",
                p: 2,
            }}
        >
            {selectedPage === 'overview' && <OverviewPage user={user} />}
        </Box>


    );
}
