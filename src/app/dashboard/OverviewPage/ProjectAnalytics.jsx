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

import { BarChart } from '@mui/x-charts/BarChart';

export default function ProjectAnalytics({
    user,
}) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const values = [60, 20, 10, 70, 50, 60, 40];

    return (
        <Grid size={6}>
            <Box
                sx={{
                    backgroundColor: '#f8f9f9',
                    borderRadius: '20px',
                    border: '3px solid #e0e0e0',
                    p: 2,
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
                    Project Analytics
                </Typography>
                <Box
                    sx={{
                        //pr: 2,
                        //pt: 2,
                    }}
                >
                    <BarChart
                        xAxis={[{
                            scaleType: 'band',
                            data: days,
                            tickLabelStyle: {
                                fontSize: 12,
                                fontFamily: 'Poppins',
                            },
                        }]}
                        yAxis={[{
                            axisLine: { visible: false },
                            tickLabelStyle: {
                                fontSize: 12,
                                fontFamily: 'Poppins',
                            },
                            grid: { visible: false },
                            valueFormatter: (v) => `${v}%`,
                        }]}
                        series={[{
                            data: values,
                            type: 'bar',
                            color: '#1976d2',
                            valueFormatter: (v) => `${v}%`,
                            itemStyle: {
                                borderRadius: 6,
                            },
                            //label: true,
                            /*label: {
                                visible: true,
                                position: 'top',
                                //formatter: (v) => `${v}%`,
                                style: {
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fill: '#333',
                                },
                            },*/
                        }]}
                        height={300}
                        /*slotProps={{
                            legend: { hidden: true },
                        }}*/
                        borderRadius={20}
                        grid={{ horizontal: false, vertical: false }}
                    />
                </Box>
            </Box>
        </Grid>
    );
}
