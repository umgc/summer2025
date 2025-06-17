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


//Custom Components
import AnimatedButton from "@/app/Buttons/AnimatedButton";
import ProjectCards from './ProjectCards';
import ProjectAnalytics from './ProjectAnalytics';
import StudentStats from './StudentStats';
import ProjectList from './ProjectList';
import TeamMembers from './TeamMembers';

export default function OverviewPage({
    user,
}) {

    return (
        <Grid
            container
            spacing={2}
            sx={{
                zIndex: 2001,
                p: 1,
            }}
        >
            <Grid size={9}>
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
                            xl: '2vw',
                        },
                    }}
                >
                    Dashboard
                </Typography>
                <Typography
                    sx={{
                        textAlign: "left",
                        color: "black",
                        //lineHeight: 1.2,
                        fontWeight: 400,
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
                    Plan, prioritize, and track your work.
                </Typography>
            </Grid>

            <Grid size={3}>
                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'row',
                        justifyContent: 'flex-end',
                        alignItems: 'center',
                        height: '100%',
                        gap: 2,
                    }}
                >
                    <AnimatedButton
                        color="#87CEEB"
                        reverse={true}
                        borderRadius="50px"
                        hoverTextColor="black"
                        reverseHoverColor="black"
                        size="large"
                        text="Add Project"
                        border="3px solid #87CEEB"
                        fullWidth={false}
                        startIcon={<Add />}
                    //onclick={handleSignInDefault}
                    />
                    <AnimatedButton
                        color="black"
                        reverse={false}
                        borderRadius="50px"
                        hoverTextColor="#87CEEB"
                        reverseHoverColor="black"
                        size="large"
                        text="Export Data"
                        border="3px solid #87CEEB"
                        fullWidth={false}
                        endIcon={<ImportExport />}
                    //onclick={handleSignInDefault}
                    />
                </Box>
            </Grid>

            <ProjectCards />
            <StudentStats />
            <ProjectAnalytics />
            <ProjectList />
            <TeamMembers user={user} />
            
        </Grid>
    );
}
