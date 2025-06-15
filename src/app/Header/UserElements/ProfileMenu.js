'use client'
import React, { useState } from 'react';
import {
    Box,
    Dialog,
    IconButton,
    Tooltip,
    Avatar,
    Menu,
    MenuItem,
    Typography,
    Divider,
    Button,
} from '@mui/material';
import { useRouter } from 'next/navigation';

//Icons
import { Logout, Person, Settings } from '@mui/icons-material';

//Supabase
//import { handleSignOut } from '../Signin/actions';

export default function ProfileMenu({ 
    user,
    handleSignOut,
    handleMenuOpen,
    handleProfile,
    handleDashboard,
}) {

    const router = useRouter();
    const [anchorEl, setAnchorEl] = useState(null);
    const open = Boolean(anchorEl);
    const handleOpen = (event) => setAnchorEl(event.currentTarget);
    const handleClose = () => setAnchorEl(null);

    const avatarSize = {
        xs: "1vw",
        sm: "1vw",
        md: "1vw",
        lg: "1vw",
        xl: "2vw",
    }

    const menuItemIconSize = {
        xs: "1vw",
        sm: "1vw",
        md: "1vw",
        lg: "1vw",
        xl: "1vw",
    }

    const menuItemIconSX = {
        width: menuItemIconSize,
        height: menuItemIconSize,
    }

    const menuItems = [
        { label: 'Profile', icon: <Person sx={menuItemIconSX} />, href: '/' },
        { label: 'Account', icon: <Settings sx={menuItemIconSX} />, href: '/' },
        { label: 'Dashboard', icon: <Settings sx={menuItemIconSX} />, href: '/' },
        { label: 'Other', icon: <Settings sx={menuItemIconSX} /> },
    ];

    const onLogout = async () => {
        handleClose();
        await handleSignOut();
        router.push('/');
    };

    const handleSubscriptionCancel = async () => {
        console.log('Cancel subscription:', user);
        const res = await fetch('/api/create-portal-session', {
            method: 'POST',
            body: JSON.stringify({ userId: user.id }),
        })
        const data = await res.json()
        if (data.url) {
            window.location.href = data.url
        } else {
            alert('Unable to open billing portal')
        }
    }

    return (
        <Box
            sx={{
                position: 'relative',
            }}
        >
            <Tooltip title="Profile settings">
                <IconButton
                    onClick={handleOpen}
                    sx={{
                        '&:hover': {
                            transform: 'scale(1.2)',
                            transition: 'transform 0.2s ease-in-out',
                        },
                    }}
                >
                    <Avatar
                        alt="User Avatar"
                        src={user?.user_metadata?.avatar_url}
                        sx={{
                            width: avatarSize,
                            height: avatarSize,
                        }}
                    />
                </IconButton>
            </Tooltip>

            <Box>
                <Menu
                    id="profile-menu"
                    anchorEl={anchorEl}
                    open={open}
                    onClose={handleClose}
                    anchorOrigin={{
                        vertical: 'bottom',
                        horizontal: 'right',
                    }}
                    keepMounted
                    transformOrigin={{
                        vertical: 'top',
                        horizontal: 'right',
                    }}
                    slotProps={{
                        paper: {
                            sx: {
                                //border: '5px solid black',
                                borderRadius: '20px',
                                p: 1,
                            }
                        }
                    }}
                >
                    <Box
                        sx={{
                            px: 2,
                            pb: 1.5,
                            textAlign: 'left',
                        }}
                    >
                        <Typography
                            noWrap
                            sx={{
                                fontFamily: 'Roboto',
                                fontWeight: 600,
                                fontSize: {
                                    xs: '1.1vw',
                                    sm: '1.2vw',
                                    md: '1.3vw',
                                    lg: '1.4vw',
                                    xl: '.9vw',
                                },
                            }}
                        >
                            {user?.user_metadata?.full_name || user?.user_metadata?.displayName || user?.email}
                        </Typography>
                        <Typography
                            noWrap
                            sx={{
                                fontFamily: 'Poppins',
                                fontWeight: 400,
                                fontSize: {
                                    xs: '1.1vw',
                                    sm: '1.2vw',
                                    md: '1.3vw',
                                    lg: '1.4vw',
                                    xl: '.6vw',
                                },
                                color: "gray"
                            }}
                        >
                            {user?.email}
                        </Typography>
                    </Box>

                    <Divider />

                    {/* Menu Links */}
                    <Box
                        sx={{
                            py: 1,
                            px: 1
                        }}
                    >
                        {menuItems.map((item) => (
                            <MenuItem
                                key={item.label}
                                onClick={() => {
                                    if (item.label === 'Cancel') {
                                        handleSubscriptionCancel();
                                        return;
                                    }
                                    
                                    handleClose();
                                    router.push(item.href);
                                }}
                                sx={{
                                    px: 1,
                                    borderRadius: '10px',
                                    '&:hover': {
                                        backgroundColor: '#87CEEB',
                                        transition: 'background-color 0.2s ease-in-out',
                                    },
                                }}
                            >
                                <Box
                                    sx={{
                                        mr: 1,
                                        display: 'flex',
                                        alignItems: 'center',

                                    }}
                                >
                                    {item.icon}
                                </Box>

                                <Typography
                                    noWrap
                                    sx={{
                                        fontFamily: 'Poppins',
                                        fontWeight: 400,
                                        fontSize: {
                                            xs: '1.1vw',
                                            sm: '1.2vw',
                                            md: '1.3vw',
                                            lg: '1.4vw',
                                            xl: '.75vw',
                                        },
                                        color: "black"
                                    }}
                                >
                                    {item.label}
                                </Typography>
                            </MenuItem>
                        ))}
                    </Box>

                    <Divider sx={{ my: 1 }} />

                    {/* Logout Button */}
                    <Box
                        sx={{
                            pt: 1,
                            px: 1
                        }}
                    >
                        <MenuItem
                            onClick={onLogout}
                            sx={{
                                px: 1,
                                borderRadius: '10px',
                                '&:hover': {
                                    backgroundColor: '#87CEEB',
                                    transition: 'background-color 0.2s ease-in-out',
                                },
                                justifyContent: 'center',
                            }}
                        >
                            <Box
                                sx={{
                                    mr: 1,
                                    display: 'flex',
                                    alignItems: 'center',
                                    color: 'error.main'
                                }}
                            >
                                <Logout sx={menuItemIconSX} />
                            </Box>
                            <Typography
                                noWrap
                                sx={{
                                    fontFamily: 'Poppins',
                                    fontWeight: 400,
                                    fontSize: {
                                        xs: '1.1vw',
                                        sm: '1.2vw',
                                        md: '1.3vw',
                                        lg: '1.4vw',
                                        xl: '.75vw',
                                    },
                                    color: "error.main",
                                }}
                            >
                                Log Out
                            </Typography>
                        </MenuItem>
                    </Box>

                </Menu>
            </Box>
        </Box>
    )
}
