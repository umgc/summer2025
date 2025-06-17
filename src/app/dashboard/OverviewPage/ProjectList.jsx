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
import { Edit } from 'lucide-react';

// List of User's Projects
export default function ProjectList({
    user,
}) {

    const testProjects = [
        {
            title: 'Project Alpha',
            description: 'A groundbreaking project that aims to revolutionize the industry.',
            status: 'In Progress',
            teamMembers: 5,
            lastUpdated: '2023-10-01',
        },
        {
            title: 'Project Beta',
            description: 'An innovative project focused on sustainability and green technology.',
            status: 'Completed',
            teamMembers: 3,
            lastUpdated: '2023-09-15',
        },
        {
            title: 'Project Gamma',
            description: 'A research project exploring new frontiers in artificial intelligence.',
            status: 'Pending',
            teamMembers: 4,
            lastUpdated: '2023-08-30',
        },
    ];

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
                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'row',
                        justifyContent: 'space-between',
                        gap: 2,
                        alignItems: 'center',
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
                        Recent Simulations
                    </Typography>

                    <AnimatedButton
                        color="black"
                        reverse={false}
                        borderRadius="50px"
                        hoverTextColor="white"
                        reverseHoverColor="black"
                        size="large"
                        text="New"
                        border="2px solid black"
                        fullWidth={false}
                        startIcon={<Add />}
                    //onclick={handleSignInDefault}
                    />
                </Box>

                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'column',
                        justifyContent: 'center',
                        gap: 2,
                        //mt: 1,
                        px: 2,
                        pt: 2,
                    }}
                >
                    {testProjects.map((item, index) => (
                        <Box
                            key={index}
                            sx={{
                                display: 'flex',
                                flexDirection: 'row',
                                justifyContent: 'space-between',
                                alignItems: 'center',
                                backgroundColor: '#f8f9f9',
                                borderRadius: '10px',
                                border: '2px solid #e0e0e0',
                                p: 1,
                                px: 2,
                            }}
                        >
                            <Box
                                sx={{
                                    display: 'flex',
                                    flexDirection: 'column',
                                    justifyContent: 'center',
                                    alignItems: 'flex-start',
                                    gap: 1,
                                }}
                            >
                                <Typography
                                    key={index}
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
                                            xl: '1vw',
                                        },
                                    }}
                                >
                                    {item.title}
                                </Typography>
                                <Typography
                                    key={index}
                                    sx={{
                                        textAlign: "left",
                                        color: "gray",
                                        lineHeight: 1,
                                        fontWeight: 300,
                                        fontFamily: 'Poppins',
                                        fontSize: {
                                            xs: '1.1vw',
                                            sm: '1.2vw',
                                            md: '1.3vw',
                                            lg: '1.4vw',
                                            xl: '.8vw',
                                        },
                                    }}
                                >
                                    Last Updated: {item.lastUpdated}
                                </Typography>
                            </Box>

                            <AnimatedButton
                                color="#87CEEB"
                                reverse={true}
                                borderRadius="999px"
                                hoverTextColor="black"
                                reverseHoverColor="black"
                                size="medium"
                                text="New"
                                border="3px solid #87CEEB"
                                fullWidth={false}
                                startIcon={<Edit />}
                                iconOnly={true}
                            //onclick={handleSignInDefault}
                            />
                        </Box>
                    ))}

                </Box>

            </Box>
        </Grid>
    );
}
