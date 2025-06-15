import React from 'react';
import { Box } from '@mui/material';

//Custom
import AppBarHeader from './AppBar';
//import MobileAppBar from './MobileAppBar';
//import FlyoutAppBarElement from './AppBar/FlyoutAppBar';

export default function Header() {

  return (
    <Box>
      <Box sx={{ display: { xs: 'none', md: 'block' } }}>
        <AppBarHeader />
      </Box>

      {/* Mobile/Tablet only */}
      {/*<Box sx={{ display: { xs: 'block', md: 'none' } }}>
        <MobileAppBar />
      </Box>*/}
    </Box>
  )
}
