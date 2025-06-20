'use client';
import React, { useState, useEffect } from 'react';
import {
    Box,
    Typography,
    Grid,
} from "@mui/material";
import { useParams } from "next/navigation";
//import MuxPlayer from '@mux/mux-player-react';

// Icons
import { Upload, Save, PlayArrow } from "@mui/icons-material";

import ReactFlow, {
    ReactFlowProvider,
    Background,
    Controls,
    MiniMap,
    addEdge,
    Panel,
    useNodesState,
    useEdgesState,
} from "reactflow"

// Supabase
import { createClient } from "@/utils/supabase/client";

// Custom Components
import CoursePageElement from './coursePage';
import AnimatedButton from "@/app/Buttons/AnimatedButton";
import LoadDialog from '../NodeCreation/LoadDialog/LoadDialog';

export default function CoursePageMain({
    user
}) {
    const { course } = useParams(); // Get course from URL
    const [data, setData] = useState({});
    //const [user, setUser] = useState(null);
    const [courseLoading, setCourseLoading] = useState(true);

    const [snackbar, setSnackbar] = useState({ open: false, message: "", severity: "info" })
    const [openSaveDialog, setOpenSaveDialog] = useState(false);
    const [openLoadDialog, setOpenLoadDialog] = useState(false);
    const [nodes, setNodes, onNodesChange] = useNodesState([]);
    const [edges, setEdges, onEdgesChange] = useEdgesState([]);
    const [currentProject, setCurrentProject] = useState({});

    /*useEffect(() => {
        // This effect runs only once when the component mounts
        const fetchData = async () => {
            // Get user from Supabase Auth    
            const supabase = await createClient();
            const {
                data: { user },
                error: userError
            } = await supabase.auth.getUser();

            if (userError) {
                console.error("Error getting user:", userError);
            } else {
                setUser(user);
                console.log("User:", user);
            }
        };

        fetchData();
    }, []);

    useEffect(() => {
        if (!course) return;
        setCourseLoading(true);

        const courseIdFromSlug = course.split("-").pop(); // e.g. 'intro-to-course-4' → '4'
    
        const fetchCourse = async (id) => {
            const res = await fetch(`/api/getCourse?id=${id}`);
            const data = await res.json();
            console.log("Course Data:", data);
            setData(data);
            setCourseLoading(false);
        };

        fetchCourse(courseIdFromSlug);
    }, [course]);*/

    const showSnackbar = (message, severity = "info") => {
        setSnackbar({ open: true, message, severity })
    }

    const loadWorkflow = () => {
        setOpenLoadDialog(true); // Open the load dialog
    }

    const handleClose = () => {
        setOpenSaveDialog(false);
        setOpenLoadDialog(false);
    }


    return (
        <Grid
            container
            spacing={2}
            sx={{
                zIndex: 2001,
                p: 1,
                //alignItems: 'stretch',
                //height: '100%',
                overflow: "hidden",
            }}
        >
            <Grid size={9}>
                <Typography
                    sx={{
                        textAlign: "left",
                        color: "black",
                        lineHeight: 1,
                        fontWeight: 600,
                        fontFamily: 'Poppins',
                        fontSize: {
                            xs: '1.1vw',
                            sm: '1.2vw',
                            md: '1.3vw',
                            lg: '1.4vw',
                            xl: '2vw',
                        },
                    }}
                >
                    Training Simulation
                </Typography>
                <Typography
                    sx={{
                        textAlign: "left",
                        color: "black",
                        //lineHeight: 1.2,
                        fontWeight: 400,
                        fontFamily: 'Poppins',
                        fontSize: {
                            xs: '1.1vw',
                            sm: '1.2vw',
                            md: '1.3vw',
                            lg: '1.4vw',
                            xl: '1vw',
                        },
                    }}
                >
                    Current Simulation: <strong>{currentProject?.name || "Select or Load a simulation to begin"}</strong>
                </Typography>
            </Grid>

            <Grid size={3}>
                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'row',
                        justifyContent: 'flex-end',
                        alignItems: 'center',
                        height: '100%',
                        gap: 2,
                    }}
                >

                    <AnimatedButton
                        color="black"
                        reverse={false}
                        borderRadius="50px"
                        hoverTextColor="#87CEEB"
                        reverseHoverColor="black"
                        size="large"
                        text="Load"
                        border="3px solid #87CEEB"
                        fullWidth={false}
                        endIcon={<Upload />}
                        onclick={loadWorkflow}
                    />

                    <AnimatedButton
                        color="#87CEEB"
                        reverse={true}
                        borderRadius="50px"
                        hoverTextColor="black"
                        reverseHoverColor="black"
                        size="large"
                        text="Start"
                        border="3px solid #87CEEB"
                        fullWidth={false}
                        endIcon={<PlayArrow />}
                    //onclick={executeWorkflow}
                    //loading={executeLoading}
                    />
                </Box>
            </Grid>

            <Grid size={12}>
                <CoursePageElement
                    data={data}
                    courseLoading={courseLoading}
                    user={user}
                />
            </Grid>

            <LoadDialog
                open={openLoadDialog}
                onClose={handleClose}
                user={user}
                nodes={nodes}
                edges={edges}
                setEdges={setEdges}
                setNodes={setNodes}
                showSnackbar={showSnackbar}
                setCurrentProject={setCurrentProject}
            />
        </Grid>
    );
}
