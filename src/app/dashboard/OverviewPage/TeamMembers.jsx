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

// List of User's Projects
export default function TeamMembers({
    user,
}) {

    const members = [
        {
            name: 'John Smith',
            workingOn: 'Project Alpha',
            description: 'A groundbreaking project that aims to revolutionize the industry.',
            status: 'In Progress',
            teamMembers: 5,
            lastUpdated: '2023-10-01',
        },
        {
            name: 'Jane Doe',
            workingOn: 'Project Beta',
            description: 'An innovative project focused on sustainability and green technology.',
            status: 'Completed',
            teamMembers: 3,
            lastUpdated: '2023-09-15',
        },
        {
            name: 'Cool Guy',
            workingOn: 'Project Gamma',
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
                        Team Collaboration
                    </Typography>

                    <AnimatedButton
                        color="black"
                        reverse={false}
                        borderRadius="50px"
                        hoverTextColor="white"
                        reverseHoverColor="black"
                        size="large"
                        text="Add Member"
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
                    {members.map((item, index) => (
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
                                    flexDirection: 'row',
                                    justifyContent: 'flex-start',
                                    alignItems: 'center',
                                    gap: 2,
                                }}
                            >
                                <Avatar
                                    sx={{
                                        width: 50,
                                        height: 50,
                                        backgroundColor: '#87CEEB',
                                        fontSize: '1.5rem',
                                        fontWeight: 'bold',
                                        color: 'white',
                                    }}
                                />

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
                                        {item.name}
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
                                        Working on: {item.workingOn}
                                    </Typography>
                                </Box>
                            </Box>

                            <Box
                                sx={{
                                    display: 'flex',
                                    flexDirection: 'column',
                                    justifyContent: 'center',
                                    alignItems: 'flex-end',
                                    gap: 1,
                                    borderRadius: '999px',
                                }}
                            >
                                <Typography
                                    key={index}
                                    sx={{
                                        border: `1px solid ${item.status === 'In Progress' 
                                            ? '#87CEEB' 
                                            : item.status === 'Completed' 
                                            ? 'green' : 'orange'
                                        }`,
                                        borderRadius: '999px',
                                        backgroundColor: item.status === 'In Progress' 
                                            ? '#87CEEB' 
                                            : item.status === 'Completed' 
                                            ? 'green' : 'orange'
                                        ,
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
                                            xl: '.5vw',
                                        },
                                        p: "6px",
                                    }}
                                >
                                    {item.status}
                                </Typography>
                            </Box>
                        </Box>
                    ))}

                </Box>

            </Box>
        </Grid>
    );
}
