"use client"
import * as React from "react"
import {
    Box,
    Typography,
    Paper,
    Tabs,
    Tab,
    Divider,
    IconButton,
    Grid,
    Tooltip,
    Accordion,
    AccordionSummary,
    AccordionDetails,
    Checkbox,
    Skeleton,
} from "@mui/material"

//Icons
import {
    ChevronRight,
    ChevronLeft,
} from "lucide-react"
import {
    Close,
    ExpandMore,
    OndemandVideo,
} from "@mui/icons-material"


// Custom Components
import CourseAccordian from "./CourseAccordians"

export default function SidebarElement({
    data,
    sidebarOpen, toggleSidebar,
    maxheight, courseLoading,
}) {

    return (
        <Box
            sx={{
                position: "relative",
                height: "100%",
                width: "100%",
                maxHeight: maxheight,
                pr: .5,
            }}
        >
            {!sidebarOpen && (
                <Tooltip title="Open Panel" placement="right">
                    <IconButton
                        onClick={toggleSidebar}
                        sx={{
                            position: "absolute",
                            left: -75, // Place it outside the sidebar
                            top: 100,
                            width: 80,
                            height: 50,
                            borderRadius: "10px 0px 0px 10px",
                            bgcolor: "#87CEEB",
                            color: "black",
                            zIndex: 1001,
                            '&:hover': {
                                bgcolor: "white",
                                color: "black",
                                border: "5px solid #87CEEB",
                            }
                        }}
                    >
                        {sidebarOpen ? <ChevronRight /> : <ChevronLeft />}
                    </IconButton>
                </Tooltip>
            )}

            {/* Sidebar content only shown if open */}
            <Box
                sx={{
                    height: "100%",
                    width: "100%",
                    display: sidebarOpen ? "flex" : "none",
                    flexDirection: "column",
                    borderRadius: 0,
                    overflow: "hidden" // Prevent outer overflow
                }}
            >
                <Box
                    sx={{
                        p: 2,
                        borderBottom: 1,
                        borderColor: "divider",
                        display: "flex",
                        flexDirection: "row",
                        alignItems: "center",
                        justifyContent: "space-between",
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
                                xl: '1vw',
                            },
                        }}
                    >
                        Course Content
                    </Typography>

                    <Tooltip title="Close Panel" placement="bottom">
                        <IconButton
                            onClick={toggleSidebar}
                            sx={{
                                bgcolor: "#87CEEB",
                                color: "black",
                                '&:hover': {
                                    bgcolor: "black",
                                    color: "white",
                                }
                            }}
                        >
                            <Close />
                        </IconButton>
                    </Tooltip>
                </Box>

                <CourseAccordian
                    data={data}
                    courseLoading={courseLoading}
                />

            </Box>
        </Box>
    );
}
