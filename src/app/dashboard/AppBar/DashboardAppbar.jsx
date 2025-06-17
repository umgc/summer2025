'use client';
import React from 'react';
import {
    Box,
    CssBaseline,
    Drawer,
    AppBar,
    Toolbar,
    Typography,
    Grid,
} from '@mui/material';

//Custom Components
import ProfileMenu from '@/app/Header/UserElements/ProfileMenu';
import DashboardSearch from './DashboardSearch';

export default function DashboardAppbar({
    drawerWidth, miniDrawerWidth, open, user,
    drawerHeightApp, drawerWidthApp, miniDrawerWidthApp
}) {


    return (
        <AppBar
            //position="fixed"
            sx={{
                height: "100%",
                ml: open ? drawerWidth : miniDrawerWidth,
                //width: `calc(100% - ${open ? drawerWidth : miniDrawerWidth})`,
                width: open ? drawerWidthApp : miniDrawerWidthApp,
                transition: (theme) =>
                    theme.transitions.create(['margin', 'width'], {
                        easing: theme.transitions.easing.sharp,
                        duration: theme.transitions.duration.standard,
                    }),
                zIndex: (theme) => theme.zIndex.drawer - 1,
                backgroundColor: 'white',
                boxShadow: 0,
            }}
        >
            <Toolbar
                sx={{
                    height: drawerHeightApp,
                    m: 2,
                    ml: 1,
                    backgroundColor: "#f0f0f0",
                    borderRadius: "20px",
                }}
            >
                <Grid
                    container
                    spacing={2}
                    sx={{
                        width: '100%',
                        height: '100%',
                        display: 'flex',
                        alignItems: 'center',
                    }}
                >
                    <Grid size={2}>
                        <DashboardSearch/>
                    </Grid>

                    <Grid
                        size="grow"
                        sx={{
                            display: 'flex',
                            justifyContent: 'flex-end',
                            alignItems: 'center',
                        }}
                    >
                        <ProfileMenu user={user}/>
                    </Grid>
                </Grid>
            </Toolbar>
        </AppBar>

    );
}
