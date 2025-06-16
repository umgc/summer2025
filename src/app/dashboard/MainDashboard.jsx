'use client';
import React, { useState } from 'react';
import { Box } from '@mui/material';

import DashboardDrawer from './Drawer/DashboardDrawer';
import DashboardAppbar from './AppBar/DashboardAppbar';

export default function MainDashboard({user}) {
  const [open, setOpen] = useState(false);

  const drawerWidth = {
    xs: "15vw",
    sm: "15vw",
    md: "15vw",
    lg: "15vw",
    xl: "10vw",
  };

  const miniDrawerWidth = {
    xs: "5vw",
    sm: "4vw",
    md: "3vw",
    lg: "2vw",
    xl: "2vw",
  };

  return (
    <Box sx={{ display: 'flex', height: '100%', backgroundColor: 'white' }}>
      <DashboardDrawer
        drawerWidth={drawerWidth}
        miniDrawerWidth={miniDrawerWidth}
        open={open}
        setOpen={setOpen}
      />

      <DashboardAppbar
        drawerWidth={drawerWidth}
        miniDrawerWidth={miniDrawerWidth}
        open={open}
        user={user}
      />      
    </Box>
  );
}
