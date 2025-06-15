'use client';
import React from 'react';
import { Box, Dialog } from '@mui/material';
import { useRouter } from 'next/navigation';

//Custom
import ProfileMenu from './ProfileMenu';
import AnimatedButton from '@/app/Buttons/AnimatedButton';

import { ArrowForward, ArrowOutward } from '@mui/icons-material';

export default function UserSection({
    user,
    handleSignOut,
    handleMenuOpen,
    handleProfile,
    handleDashboard
}) {
    const router = useRouter();

    return (
        <Box
            sx={{
                display: "flex",
                flexDirection: "row",
                justifyContent: "flex-end",
                alignItems: "center",
                gap: 2,
            }}
        >
            <AnimatedButton
                color={"black"}
                reverse={true}
                borderRadius="50px"
                hoverTextColor={"white"}
                size="large"
                text="Dashboard"
                border={`3px solid black`}
                endIcon={<ArrowOutward />}
                onclick={handleDashboard}
            />
            <ProfileMenu
                user={user}
                handleSignOut={handleSignOut}
                handleMenuOpen={handleMenuOpen}
                handleProfile={handleProfile}
                handleDashboard={handleDashboard}
            />
        </Box>
    )
}
