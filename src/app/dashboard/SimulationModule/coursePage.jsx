"use client"
import * as React from "react"
import {
    Box,
    Grid,
} from "@mui/material"


// Custom Components
import MainVideoElement from "./CourseElements/MainVideo"
//import SidebarElement from "./CourseElements/Sidebar/Sidebar"
//import CourseTabsElement from "./CourseElements/CourseTabs"

export default function CoursePageElement({
    data,
    courseLoading,
    user,
}) {
    const [sidebarOpen, setSidebarOpen] = React.useState(true)
    const maxheight = "40vw"

    const toggleSidebar = () => {
        setSidebarOpen(!sidebarOpen)
    }

    React.useEffect(() => {
        if (data && data.sections && data.sections.length > 0) {
            // If there are sections, ensure sidebar is open
            setSidebarOpen(true)
        } else {
            // If no sections, close the sidebar
            setSidebarOpen(false)
        }
    }, [data.sections])

     const loadWorkflow = () => {
        setOpenLoadDialog(true); // Open the load dialog
    }

    return (

        <Grid
            container
            sx={{
                display: "flex",
                flexDirection: "row",
                bgcolor: "background.default"
            }}
        >

            <Grid
                size={sidebarOpen ? 10 : 12}
                sx={{
                    display: "flex",
                    p: 2,
                    transition: "width 0.3s ease",
                }}
            >
                <MainVideoElement
                    data={data}
                    maxheight={maxheight}
                />
            </Grid>

            {/*data && data.sections && data.sections.length > 0 && (
                <Grid
                    size={sidebarOpen ? 2 : 0}
                    sx={{
                        transition: "width 0.3s ease",
                        overflow: "visible",
                    }}
                >
                    <SidebarElement
                        data={data}
                        sidebarOpen={sidebarOpen}
                        toggleSidebar={toggleSidebar}
                        maxheight={maxheight}
                        courseLoading={courseLoading}
                    />
                </Grid>
            )*/}

            <Grid
                size={12}
            >
                {/*<CourseTabsElement
                    data={data}
                    courseLoading={courseLoading}
                    user={user}
                />*/}
            </Grid>

        </Grid>

    );
}