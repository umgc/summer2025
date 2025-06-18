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
    Add,
    Update,
} from '@mui/icons-material';

//custom components
import AnimatedButton from "@/app/Buttons/AnimatedButton";
import DateCalendarServerRequest from './DateCalendarServerRequest';

// List of User's Projects
export default function Reminders({
    user,
}) {

    return (
        <Grid size={2} sx={{ height: '100%', }}>
            <Box
                sx={{
                    backgroundColor: '#f8f9f9',
                    borderRadius: '20px',
                    border: '3px solid #e0e0e0',
                    p: 2,
                    pb:  0,
                    height: '100%',
                    minHeight: '30vh',
                    //maxHeight: '30vh',
                    overflow: 'hidden',
                }}
            >
                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'row',
                        justifyContent: 'space-between',
                        gap: 2,
                        alignItems: 'center',
                        //mb: 3,
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
                        Reminders
                    </Typography>

                    <AnimatedButton
                        color="black"
                        reverse={false}
                        borderRadius="50px"
                        hoverTextColor="white"
                        reverseHoverColor="black"
                        size="medium"
                        text="Add Task"
                        border="2px solid black"
                        fullWidth={false}
                        startIcon={<Add />}
                    //onclick={handleSignInDefault}
                    />
                </Box>

                <Box
                    sx={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'flex-start',
                        height: '100%',
                        mb: -4,
                                                //overflow: 'hidden',
                        //mx: 1,
                        //transform: 'scale(1.25)', // increase to make it bigger (e.g., 1.5 for 150%)
                        //transformOrigin: 'center center', // keep it aligned nicely
                    }}
                >
                    <DateCalendarServerRequest />
                </Box>


            </Box>
        </Grid>
    );
}
