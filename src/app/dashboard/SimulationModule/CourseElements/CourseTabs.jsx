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
    IconButton
} from "@mui/material"
import { Menu, ChevronRight, PlayCircle, Download, CheckCircle, Award } from "lucide-react"

// Custom Components
import OverviewTab from "./TabSections/OverviewTab"
import CourseAccordian from "./Sidebar/CourseAccordians"
import CourseReviews from "./TabSections/reviews/Reviews"
import QuestionsTab from "./TabSections/QA/questionSection"


export default function CourseTabsElement({ data, courseLoading, user }) {
    const [value, setValue] = React.useState(0)

    const handleChange = (event, newValue) => {
        setValue(newValue)
    }

    return (
        <Box
            sx={{
                width: "100%",
                px: 3,
                pb: 3,
            }}
        >
            <Tabs
                value={value}
                onChange={handleChange}
                variant="scrollable"
                scrollButtons="auto"
                sx={{
                    borderBottom: 1,
                    borderColor: "divider",
                    "& .MuiTab-root": {
                        textTransform: "none",
                        fontFamily: 'Poppins',
                        fontWeight: 600,
                        fontSize: {
                            xs: '1.1vw',
                            sm: '1.2vw',
                            md: '1.3vw',
                            lg: '1.4vw',
                            xl: '.75vw',
                        },
                        color: "black"
                    },
                }}
            >
                <Tab label="Overview" />                
                <Tab label="Reviews" />
                <Tab label="Q&A" />
                {data && data.sections && data.sections.length > 0 && (
                    <Tab label="Course Content" />
                )}
                {/*<Tab label="Resources" />*/}
            </Tabs>

            <TabPanel value={value} index={0}>
                <OverviewTab data={data} />
            </TabPanel>

            <TabPanel value={value} index={1}>
                <CourseReviews
                    data={data}
                    courseLoading={courseLoading}
                    user={user}
                />
            </TabPanel>

            <TabPanel value={value} index={2}>
                {user ? (
                    <QuestionsTab
                        data={data}
                        courseLoading={courseLoading}
                        user={user}
                    />
                ) : (
                    <Box
                        sx={{
                            display: 'flex',
                            flexDirection: 'column',
                            justifyContent: 'center',
                            alignItems: 'center',
                        }}
                    >
                        <Typography
                            sx={{
                                textAlign: "center",
                                fontSize: {
                                    xs: '8vw',
                                    sm: '4vw',
                                    md: '3vw',
                                    lg: '2vw',
                                    xl: '1.25vw',
                                },
                                fontFamily: 'Poppins',
                                fontWeight: 600,
                                color: "black",
                            }}
                        >
                            Please log in to view Q&A
                        </Typography>
                    </Box>
                )}
            </TabPanel>

            <TabPanel value={value} index={3}>
                <CourseAccordian
                    data={data}
                    courseLoading={courseLoading}
                />
            </TabPanel>
        </Box>

    )
}

// Tab Panel component
function TabPanel(props) {
    const { children, value, index, ...other } = props

    return (
        <div role="tabpanel" hidden={value !== index} id={`tabpanel-${index}`} aria-labelledby={`tab-${index}`} {...other}>
            {value === index && <Box>{children}</Box>}
        </div>
    )
}
