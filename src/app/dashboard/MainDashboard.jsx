'use client';
import React, { useState } from 'react';
import { Box } from '@mui/material';

import DashboardDrawer from './Drawer/DashboardDrawer';
import DashboardAppbar from './AppBar/DashboardAppbar';
import DashboardPage from './DashboardPage/DashboardPage';

export default function MainDashboard({ user }) {
  const [open, setOpen] = useState(false);
  const [selectedPage, setSelectedPage] = useState('overview');
  console.log("Selected Page:", selectedPage);

  // Drawer dimensions
  const drawerWidth = {
    xs: "10%",
    sm: "10%",
    md: "10%",
    lg: "10%",
    xl: "10%",
  };
  const miniDrawerWidth = {
    xs: "6%",
    sm: "5%",
    md: "4%",
    lg: "3%",
    xl: "3%",
  };

  // App-specific dimensions
  const drawerWidthApp = {
    xs: "89%",
    sm: "89%",
    md: "89%",
    lg: "89%",
    xl: "89%",
  };
  const drawerHeightApp = {
    xs: "6%",
    sm: "6%",
    md: "6%",
    lg: "6%",
    xl: "6%",
  };
  const miniDrawerWidthApp = {
    xs: "97%",
    sm: "97%",
    md: "97%",
    lg: "97%",
    xl: "96%",
  };

  return (
    <Box
      sx={{
        display: 'flex',
        position: 'relative',
        height: '100%',
        minHeight: '100vh',
        minWidth: '100vw',
        backgroundColor: 'white',
        overflow: 'hidden',
      }}
    >
      <DashboardDrawer
        drawerWidth={drawerWidth}
        miniDrawerWidth={miniDrawerWidth}
        open={open}
        setOpen={setOpen}
        setSelectedPage={setSelectedPage}
      />
      
      <DashboardAppbar
        drawerWidth={drawerWidth}
        miniDrawerWidth={miniDrawerWidth}
        drawerHeightApp={drawerHeightApp}
        drawerWidthApp={drawerWidthApp}
        miniDrawerWidthApp={miniDrawerWidthApp}
        open={open}
        user={user}
      />     
      
      <DashboardPage
        open={open}
        setOpen={setOpen}
        user={user}
        selectedPage={selectedPage}
      />
    </Box>
  );
}
