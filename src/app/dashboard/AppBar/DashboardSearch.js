'use client';
import React from "react";
import {
    Box,
    TextField,
    IconButton,
} from "@mui/material";
import SearchIcon from '@mui/icons-material/Search';

export default function DashboardSearch({}) {

    const buttonSize = {
        xs: '6vw',
        sm: '4vw',
        md: '1vw',
        lg: '1vw',
        xl: '1.25vw',
    };

    return (
        <Box
            sx={{
                display: "flex",
                flexDirection: "row",
                justifyContent: "center",
                alignItems: "center",
                backgroundColor: "black",
                borderRadius: "999px",
                //p: 1,
                minWidth: "100%",
            }}
        >
            <TextField
                placeholder="Search"
                variant="standard"
                slotProps={{
                    input: {
                        style: {
                            paddingLeft: '0.5rem',
                            fontSize: '.8vw',
                            color: 'white',
                        },
                    },
                }}
                InputProps={{
                    disableUnderline: true,
                }}
                //value={searchQuery}
                //onChange={(e) => setSearchQuery(e.target.value)}
                fullWidth
                sx={{
                    px: 2,
                    backgroundColor: "black",
                    input: {
                        '::placeholder': {
                            color: 'rgba(255, 255, 255, 0.6)',
                            opacity: 1,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '.8vw',
                            },
                        },
                    },
                    borderRadius: "999px",
                }}
            />
            <IconButton
                sx={{
                    backgroundColor: "#87CEEB",
                    borderRadius: "50%",
                    color: "black",
                    m: 1,
                    width: buttonSize,
                    height: buttonSize,
                    minWidth: '32px',
                    minHeight: '32px',
                    '&:hover': {
                        backgroundColor: "white",
                        color: "black",
                    },
                }}
                aria-label="search"
                //onClick={() => CourseChanged(selectedSection)}
                onKeyDown={(e) => {
                   // if (e.key === 'Enter') CourseChanged(selectedSection);
                }}
            >
                <SearchIcon sx={{ fontSize: '1vw' }} />
            </IconButton>
        </Box>
    );
}
