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

const studentStats = [
    {
        title: 'Total Students',
        value: '10,429',
        change: '2.5%',
        icon: <People />,
    },
    {
        title: 'Total Projects Completed',
        value: '30,212',
        change: '0.5%',
        icon: <School />,
    },
    {
        title: 'Avg. Completion Rate',
        value: '83%',
        change: '-3%',
        icon: <Grade />,
    },
]

export default function StudentStats({
    user,
}) {

    return (
        <Grid size={2}>
            <Box
                sx={{
                    display: 'flex',
                    flexDirection: 'column',
                    gap: 2,
                    height: '100%',
                    justifyContent: 'space-between',
                }}
            >
                {studentStats.map((item, index) => {
                    const changeValue = parseFloat(item.change);
                    const isPositive = changeValue >= 0;
                    const ChangeIcon = isPositive ? TrendingUp : TrendingDown;
                    const changeColor = isPositive ? 'green' : 'red';

                    return (
                        <Box
                            key={index}
                            sx={{
                                backgroundColor: '#f8f9f9',
                                borderRadius: '20px',
                                border: '3px solid #e0e0e0',
                                p: 2,
                                height: '100%',
                                display: 'flex',
                                flexDirection: 'column',
                                gap: 1,
                            }}
                        >
                            <Typography
                                sx={{
                                    textAlign: "left",
                                    color: "gray",
                                    fontWeight: 400,
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
                                    gap: 1,
                                }}
                            >
                                {item.icon} {item.title}
                            </Typography>

                            <Box
                                sx={{
                                    display: 'flex',
                                    flexDirection: 'row',
                                    gap: 1,
                                }}
                            >
                                <Typography
                                    sx={{
                                        textAlign: "left",
                                        color: "black",
                                        lineHeight: 1,
                                        fontWeight: 600,
                                        fontFamily: 'Poppins',
                                        fontSize: {
                                            xs: '1.1vw',
                                            sm: '1.2vw',
                                            md: '1.3vw',
                                            lg: '1.4vw',
                                            xl: '1.75vw',
                                        },
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: 1,
                                    }}
                                >
                                    {item.value}
                                </Typography>
                                <Typography
                                    sx={{
                                        textAlign: "left",
                                        color: changeColor,
                                        fontWeight: 600,
                                        fontFamily: 'Poppins',
                                        fontSize: {
                                            xs: '1.1vw',
                                            sm: '1.2vw',
                                            md: '1.3vw',
                                            lg: '1.4vw',
                                            xl: '.9vw',
                                        },
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: 1,
                                    }}
                                >
                                    <ChangeIcon
                                        sx={{
                                            color: changeColor,
                                            fontSize: '2.5rem'
                                        }}
                                    />
                                    {item.change}
                                </Typography>
                            </Box>
                        </Box>
                    );
                })}

            </Box>
        </Grid>
    );
}
