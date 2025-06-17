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

const items = [
    { text: 'Overview', icon: <Home /> },
    { text: 'Simulations', icon: <Business /> },
    { text: 'Social', icon: <People /> },
    { text: 'Settings', icon: <Settings /> },
];

const logo = 'https://3vsrvtbwvqgcv6z1.public.blob.vercel-storage.com/DeepTrain_Logo_small.png';

export default function DashboardDrawer({ 
    drawerWidth, miniDrawerWidth, open, setOpen, setSelectedPage 
}) {

    return (
        <Box
            sx={{
                //position: 'fixed',
                display: 'flex',
                backgroundColor: 'white',
                border: '0px solid transparent',
                overflow: 'hidden',
            }}
        >
            {/* Drawer */}
            <Drawer
                variant="permanent"
                open={open}
                sx={{
                    width: open ? drawerWidth : miniDrawerWidth,
                    flexShrink: 0,
                    whiteSpace: 'nowrap',
                    boxSizing: 'border-box',
                    px: open ? 1 : 0.5, // padding around content
                    py: 1,
                    '& .MuiDrawer-paper': {
                        width: open ? drawerWidth : miniDrawerWidth,
                        transition: (theme) =>
                            theme.transitions.create('width', {
                                easing: theme.transitions.easing.sharp,
                                duration: theme.transitions.duration.enteringScreen,
                            }),
                        overflowX: 'hidden',
                        backgroundColor: '#f0f0f0',
                        borderRadius: '25px',
                        border: '0px solid gray',
                        m: 2,
                        height: '97vh',
                        boxShadow: 0,
                    },

                }}
            >
                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'column',
                        //gap: 1,
                        //height: '90%',
                    }}
                >
                    <Toolbar sx={{ justifyContent: 'space-between' }}>
                        <Grid
                            container
                            sx={{
                                display: 'flex',
                                alignItems: 'center',
                                width: '100%',
                                height: '100%',
                            }}
                        >
                            <Grid
                                size={12}
                                sx={{
                                    display: 'flex',
                                    justifyContent: 'flex-start',
                                    alignItems: 'center',
                                }}
                            >
                                <Box
                                    sx={{
                                        display: 'flex',
                                        flexDirection: 'row',
                                        width: '100%',
                                        alignItems: 'center',
                                        justifyContent: 'center',

                                    }}
                                >
                                    {open ? (
                                        <Box>
                                            <Tooltip title="Home Page">
                                                <Link href="/" passHref>
                                                    <Typography
                                                        sx={{
                                                            fontFamily: 'Poppins',
                                                            fontWeight: 900,
                                                            fontSize: {
                                                                xs: '1.1vw',
                                                                sm: '1.2vw',
                                                                md: '1.3vw',
                                                                lg: '1.4vw',
                                                                xl: '1vw',
                                                            },
                                                            color: "black",
                                                            textTransform: "uppercase",
                                                        }}
                                                    >
                                                        DeepTrain
                                                    </Typography>
                                                </Link>
                                            </Tooltip>

                                            <Box
                                                sx={{
                                                    display: 'flex',
                                                    position: 'absolute',
                                                    right: 4,
                                                    top: 4,
                                                }}
                                            >
                                                <IconButton
                                                    color="inherit"
                                                    edge="start"
                                                    onClick={() => setOpen(false)}
                                                    sx={{ mr: 0 }}
                                                >
                                                    <Close />
                                                </IconButton>
                                            </Box>
                                        </Box>
                                    ) : (
                                        <Box>
                                            <Tooltip title="Home Page">
                                                <Link href="/" passHref>
                                                    <Box
                                                        sx={{
                                                            cursor: 'pointer',
                                                            display: 'flex',
                                                            alignItems: 'center',
                                                            width: '1.5vw',
                                                            height: '3vw',
                                                            position: 'relative',
                                                            transition: 'transform 0.3s ease, font-size 0.3s ease',
                                                            '&:hover': {
                                                                transform: 'scale(1.2)',
                                                            },
                                                        }}
                                                    >
                                                        <Image
                                                            src={logo}
                                                            alt="Logo"
                                                            fill
                                                            sizes="6vw"
                                                            style={{
                                                                objectFit: 'contain',
                                                            }}
                                                            priority
                                                        />
                                                    </Box>
                                                </Link>
                                            </Tooltip>
                                        </Box>
                                    )}
                                </Box>
                            </Grid>
                        </Grid>

                    </Toolbar>
                    <Divider />
                    <List>
                        <Box
                            sx={{
                                display: 'flex',
                                flexDirection: 'column',
                                gap: 1,
                                alignItems: 'center',
                                justifyContent: 'center',
                                height: '100%',
                            }}
                        >
                            {!open && (
                                <Box
                                    sx={{
                                        display: 'flex',
                                        justifyContent: 'center',
                                        alignItems: 'center',
                                        transition: 'transform 0.3s ease',
                                        //p: .5,
                                    }}
                                >
                                    <Tooltip title="Open Panel" placement="bottom">
                                        <IconButton
                                            onClick={() => setOpen(true)}
                                            sx={{
                                                width: 40,
                                                height: 40,
                                                borderRadius: "5px",
                                                //mt: 1,
                                                p: 0,
                                                color: "gray",
                                                '&:hover': {
                                                    bgcolor: "#87CEEB",
                                                    color: "black",
                                                    border: "2px solid #87CEEB",
                                                },

                                            }}
                                        >
                                            <ArrowForwardIos />
                                        </IconButton>
                                    </Tooltip>
                                </Box>
                            )}


                            {items.map(({ text, icon }) => (
                                <ListItem key={text} disablePadding sx={{ display: 'block' }}>
                                    <ListItemButton
                                        sx={{
                                            justifyContent: open ? 'initial' : 'center',
                                            px: open ? 2.5 : 1,
                                            borderRadius: "5px",
                                            color: "gray",
                                            transition: 'transform 0.2s ease-in-out',
                                            '&:hover': {
                                                bgcolor: "#87CEEB",
                                                color: "black",
                                                border: "2px solid #87CEEB",
                                                transform: 'scale(1.05)',
                                            },
                                            '&:hover .MuiListItemIcon-root': {
                                                color: 'black', // Explicitly change icon color
                                            },
                                            mx: open ? 1 : 'auto',
                                            width: 40,
                                            height: 40,
                                        }}
                                        onClick={() => {
                                            setSelectedPage(text.toLowerCase());                                            
                                        }}
                                    >
                                        <ListItemIcon
                                            sx={{
                                                minWidth: 0,
                                                mr: open ? 2 : 'auto',
                                                justifyContent: 'center',
                                                color: "gray",
                                                /*'&:hover': {
                                                    bgcolor: "#87CEEB",
                                                    color: "black",
                                                    border: "2px solid #87CEEB",
                                                    transform: 'scale(1.05)',
                                                },*/
                                            }}
                                        >
                                            {icon}
                                        </ListItemIcon>
                                        <ListItemText primary={text} sx={{ opacity: open ? 1 : 0 }} />
                                    </ListItemButton>

                                </ListItem>
                            ))}
                        </Box>
                    </List>

                </Box>
            </Drawer>

        </Box>
    );
}
