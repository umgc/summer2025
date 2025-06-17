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
    ArrowDropUp,
    ImportExport,
    Add,
    Done,
    DirectionsRun,
    Numbers,
    Pending,
} from '@mui/icons-material';

const projectCards = [
    {
        title: "Total Projects",
        value: "24",
        icon: <Numbers sx={{ fontSize: '2rem' }} />,
        increase: 2,
    },
    {
        title: "Ended Projects",
        value: "10",
        icon: <Done sx={{ fontSize: '2rem' }} />,
        increase: 5,
    },
    {
        title: "Running Projects",
        value: "12",
        icon: <DirectionsRun sx={{ fontSize: '2rem' }} />,
        increase: 1,
    },
    {
        title: "Pending Projects",
        value: "3",
        icon: <Pending sx={{ fontSize: '2rem' }} />,
        increase: 0,
    },
]

export default function ProjectCards({
    user,
}) {

    return (
        <>
            {projectCards.map((item, index) => (
                <Grid size={3} key={index}>
                    <Box
                        sx={{
                            height: {
                                xs: '7vw',
                                sm: '7vw',
                                md: '7vw',
                                lg: '7vw',
                                xl: '100%',
                            },
                            width: "100%",
                            backgroundColor: "#87CEEB",
                            borderRadius: "20px",
                            overflow: 'hidden',
                            p: 2,
                            display: 'flex',
                            flexDirection: 'column',
                            justifyContent: 'center',
                            alignItems: 'flex-start',
                        }}
                    >
                        <Box
                            sx={{
                                display: 'flex',
                                flexDirection: 'row',
                                justifyContent: 'space-between',
                                alignItems: 'center',
                                gap: 1,
                                width: "100%",
                            }}
                        >
                            <Typography
                                sx={{
                                    textAlign: "left",
                                    color: "black",
                                    lineHeight: 1,
                                    fontWeight: 500,
                                    fontFamily: 'Poppins',
                                    fontSize: {
                                        xs: '1.1vw',
                                        sm: '1.2vw',
                                        md: '1.3vw',
                                        lg: '1.4vw',
                                        xl: '1.2vw',
                                    },
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: 1,
                                }}
                            >
                                {item.title}
                            </Typography>
                            {item.icon}
                        </Box>

                        <Typography
                            sx={{
                                textAlign: "left",
                                color: "black",
                                lineHeight: 1,
                                fontWeight: 500,
                                fontFamily: 'Poppins',
                                fontSize: {
                                    xs: '1.1vw',
                                    sm: '1.2vw',
                                    md: '1.3vw',
                                    lg: '1.4vw',
                                    xl: '3vw',
                                },
                                pt: 2,
                            }}
                        >
                            {item.value}
                        </Typography>

                        <Box
                            sx={{
                                display: 'flex',
                                flexDirection: 'row',
                                justifyContent: 'flex-start',
                                alignItems: 'center',
                                gap: 1,
                                pt: 1,
                            }}
                        >
                            {item.increase > 0 && (
                                <Box
                                    sx={{
                                        height: "100%",
                                        borderRadius: "10%",
                                        border: "2px solid black",
                                        pl: .5,
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                    }}
                                >
                                    <Typography
                                        sx={{
                                            textAlign: "left",
                                            color: "black",
                                            //lineHeight: 1,
                                            fontWeight: 300,
                                            fontFamily: 'Poppins',
                                            fontSize: {
                                                xs: '1.1vw',
                                                sm: '1.2vw',
                                                md: '1.3vw',
                                                lg: '1.4vw',
                                                xl: '.75vw',
                                            },
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            //gap: 1,
                                        }}
                                    >
                                        {item.increase} <ArrowDropUp />
                                    </Typography>
                                </Box>
                            )}

                            <Typography
                                sx={{
                                    textAlign: "left",
                                    color: "black",
                                    //lineHeight: 1,
                                    fontWeight: 300,
                                    fontFamily: 'Poppins',
                                    fontSize: {
                                        xs: '1.1vw',
                                        sm: '1.2vw',
                                        md: '1.3vw',
                                        lg: '1.4vw',
                                        xl: '.8vw',
                                    },
                                    display: 'flex',
                                    alignItems: 'center',
                                    //gap: 1,
                                }}
                            >
                                {item.increase > 0 ? "Increase from last month" : "Waiting for Edits"}
                            </Typography>
                        </Box>

                    </Box>
                </Grid>
            ))}
        </>
    );
}
