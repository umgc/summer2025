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
    Close,
    ExpandMore,
    OndemandVideo,
} from "@mui/icons-material"


export default function CourseAccordian({
    data, courseLoading,
}) {
    const [watched, setWatched] = React.useState({});

    const parseDuration = (timeStr) => {
        const [hours, minutes, seconds] = timeStr.split(":").map(Number);
        return hours * 60 + minutes + Math.floor(seconds / 60);
    };

    const formatDuration = (totalMinutes) => {
        const hours = Math.floor(totalMinutes / 60);
        const minutes = totalMinutes % 60;
        if (hours > 0) return `${hours}h ${minutes}m`;
        return `${minutes}min`;
    };

    const handleWatchedToggle = (sectionIndex, lectureIndex) => {
        const key = `${sectionIndex}-${lectureIndex}`;
        setWatched(prev => ({
            ...prev,
            [key]: !prev[key]
        }));
    };


    return (
        <Box
            sx={{
                overflowY: "auto",
            }}
        >
            {courseLoading ? (
                Array.from({ length: 10 }).map((_, index) => (
                    <Accordion key={index} disableGutters>
                        <AccordionSummary
                            expandIcon={<ExpandMore />}
                            sx={{ bgcolor: "#f0f0f0" }}
                        >
                            <Box sx={{ width: "100%" }}>
                                <Skeleton variant="text" width="80%" height={24} />
                                <Skeleton variant="text" width="60%" height={20} />
                            </Box>
                        </AccordionSummary>
                        {/*<AccordionDetails>
                                    {Array.from({ length: 3 }).map((_, subIndex) => (
                                        <Box
                                            key={subIndex}
                                            sx={{
                                                display: 'flex',
                                                flexDirection: 'row',
                                                gap: 1,
                                                mt: 1,
                                                py: 0.5,
                                            }}
                                        >
                                            <Skeleton variant="circular" width={24} height={24} />
                                            <Box sx={{ width: "100%" }}>
                                                <Skeleton variant="text" width="90%" height={20} />
                                                <Skeleton variant="text" width="70%" height={18} />
                                            </Box>
                                        </Box>
                                    ))}
                                </AccordionDetails>*/}
                    </Accordion>
                ))
            ) : (
                data.sections?.map((section, index) => (
                    <Accordion key={index} disableGutters>
                        <AccordionSummary
                            expandIcon={<ExpandMore />}
                            aria-controls={`panel${index}-content`}
                            id={`panel${index}-header`}
                            sx={{ bgcolor: "#f0f0f0" }}
                        >
                            <Box
                                sx={{
                                    display: 'flex',
                                    flexDirection: 'column',
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
                                            xl: '.7vw',
                                        },
                                    }}
                                >
                                    {index + 1}. {section.title}
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
                                    }}
                                >
                                    {section.lectures?.length} Lectures | {formatDuration(
                                        section.lectures?.reduce((sum, lec) => sum + parseDuration(lec.duration), 0)
                                    )}

                                </Typography>
                            </Box>
                        </AccordionSummary>
                        <AccordionDetails>
                            {section.lectures?.map((lecture, lectureIndex) => {
                                const key = `${index}-${lectureIndex}`;
                                const isChecked = watched[key] || false;

                                return (
                                    <Box
                                        key={lectureIndex}
                                        sx={{
                                            display: 'flex',
                                            flexDirection: 'row',
                                            gap: 1,
                                            mt: 1,
                                            py: .5
                                        }}
                                    >
                                        <Checkbox
                                            checked={isChecked}
                                            onChange={() => handleWatchedToggle(index, lectureIndex)}
                                            sx={{
                                                display: 'flex',
                                                alignItems: 'flex-start',
                                                justifyContent: 'center',
                                            }}
                                        />

                                        <Box
                                            sx={{
                                                display: 'flex',
                                                flexDirection: 'column',
                                                //gap: 0.5,
                                                //my: .5,
                                            }}
                                        >
                                            <Typography
                                                sx={{
                                                    fontFamily: 'Poppins',
                                                    fontWeight: 500,
                                                    fontSize: {
                                                        xs: '1.1vw',
                                                        sm: '1.2vw',
                                                        md: '1.3vw',
                                                        lg: '1.4vw',
                                                        xl: '.6vw',
                                                    },
                                                }}
                                            >
                                                {lectureIndex + 1}. {lecture.title}
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
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    color: 'gray',
                                                }}
                                            >
                                                <OndemandVideo sx={{ mr: 1 }} /> {formatDuration(parseDuration(lecture.duration))}
                                            </Typography>
                                        </Box>


                                    </Box>
                                );
                            })}

                        </AccordionDetails>
                    </Accordion>
                ))
            )}
        </Box>
    );
}
