"use client"
import * as React from "react"
import {
    Box,
    Typography,
    Paper,
    Tabs,
    Tab,
    Divider,
    useMediaQuery,
    IconButton,
    Grid
} from "@mui/material"
import { Menu, ChevronRight, PlayCircle, Download, CheckCircle, Award, Gauge } from "lucide-react"
import { AccessTime, ClosedCaption, Create, Language, NewReleases, School } from "@mui/icons-material"


export default function OverviewTab({ data }) {
    console.log("OverviewTab data:", data)

    const capitalizeFirstLetter = (string) => {
        if (typeof string !== 'string' || string.length === 0) {
            return string; // Return as is if not a string or empty
        }
        return string.charAt(0).toUpperCase() + string.slice(1)
    }

    const formatToMonthYear = (isoString) => {
        if (!isoString) {
            return "Unknown Date"; // Handle case where date is not provided
        }
        const date = new Date(isoString);
        return date.toLocaleString("en-US", {
            month: "long",
            year: "numeric",
        });
    };


    return (
        <Box
            sx={{
                display: "flex",
                flexDirection: "column",
                pt: 1,
                pb: 5,
                gap: 0,
            }}
        >
            <Typography
                sx={{
                    fontFamily: 'Poppins',
                    fontWeight: 600,
                    fontSize: {
                        xs: '1.1vw',
                        sm: '1.2vw',
                        md: '1.3vw',
                        lg: '1.4vw',
                        xl: '1.5vw',
                    },
                }}
            >
                {data.course_name}
            </Typography>


            <Box
                sx={{
                    display: "flex",
                    flexDirection: "row",
                    mt: 1,
                    gap: 5,
                }}
            >
                <Box
                    sx={{
                        display: "flex",
                        flexDirection: "column",
                    }}
                >
                    <Typography
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
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                        }}
                    >
                        <Gauge style={{ marginRight: "8px" }} />
                        {capitalizeFirstLetter(data.course_level) || "Beginner"}
                    </Typography>
                    <Typography
                        sx={{
                            fontFamily: 'Poppins',
                            fontWeight: 400,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '.5vw',
                            },
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                        }}
                    >
                        Course Level
                    </Typography>
                </Box>

                <Box
                    sx={{
                        display: "flex",
                        flexDirection: "column",
                    }}
                >
                    <Typography
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
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                        }}
                    >
                        <School sx={{ mr: 1 }} /> {data.enrollment_count || 0}
                    </Typography>
                    <Typography
                        sx={{
                            fontFamily: 'Poppins',
                            fontWeight: 400,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '.5vw',
                            },
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                        }}
                    >
                        Students
                    </Typography>
                </Box>

                <Box
                    sx={{
                        display: "flex",
                        flexDirection: "column",
                    }}
                >
                    <Typography
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
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                        }}
                    >
                        <AccessTime sx={{ mr: 1 }} /> {data.course_duration || "N/A"}
                    </Typography>
                    <Typography
                        sx={{
                            fontFamily: 'Poppins',
                            fontWeight: 400,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '.5vw',
                            },
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                        }}
                    >
                        Total Time
                    </Typography>
                </Box>

            </Box>

            <Typography
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
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "flex-start",
                    mt: 2,
                }}
            >
                <Create sx={{ mr: 1 }} /> Created by {data.created_by || "Unknown"}
            </Typography>

            <Typography
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
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "flex-start",
                    mt: 1,
                }}
            >
                <NewReleases sx={{ mr: 1 }} /> Last updated {formatToMonthYear(data.last_updated)}
            </Typography>

            <Typography
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
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "flex-start",
                    mt: 1,
                }}
            >
                <Language sx={{ mr: 1 }} /> English
            </Typography>

            <Typography
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
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "flex-start",
                    mt: 1,
                }}
            >
                <ClosedCaption sx={{ mr: 1 }} /> English
            </Typography>

            <Divider sx={{ my: 3 }} />

            <Grid
                container
                spacing={5}
            >
                <Grid size={3}>
                    <Typography
                        sx={{
                            fontFamily: 'Poppins',
                            fontWeight: 500,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '.9vw',
                            },
                        }}
                    >
                        Course Description
                    </Typography>
                </Grid>
                <Grid size={9}>
                    <Typography
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
                            maxWidth: '50%',
                        }}
                    >
                        {data.course_description}
                    </Typography>
                </Grid>

                <Grid size={12}>
                    <Divider />
                </Grid>

                <Grid size={3}>
                    <Typography
                        sx={{
                            fontFamily: 'Poppins',
                            fontWeight: 500,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '.9vw',
                            },
                        }}
                    >
                        Course Tags
                    </Typography>
                </Grid>
                <Grid size={9}>
                    <Typography
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
                            maxWidth: '50%',
                        }}
                    >
                        {data.tags?.join(', ')}
                    </Typography>
                </Grid>
            </Grid>
        </Box>

    )
}