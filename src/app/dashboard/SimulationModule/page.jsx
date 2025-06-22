'use client';
import React, { useState, useEffect } from 'react';
import {
    Box,
    Typography,
    Grid,
    Snackbar,
    Alert,
    Button,
    IconButton,
} from "@mui/material";
import { useParams } from "next/navigation";
//import MuxPlayer from '@mux/mux-player-react';

// Icons
import { Upload, Save, PlayArrow, ArrowForward } from "@mui/icons-material";

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
import LessonPlayer from './LessonSim/LessonPlayer';
import DefaultRender from './DefaultRender/defaultRender';
import QuizSim from './QuizSim/QuizSim';
import CongratulationsScreen from './EndRender/congratsScreen';
import ErrorScreen from './ErrorRender/errorRender';

export default function CoursePageMain({
    user,
}) {

    const [snackbar, setSnackbar] = useState({ open: false, message: "", severity: "info" })
    const [openSaveDialog, setOpenSaveDialog] = useState(false);
    const [openLoadDialog, setOpenLoadDialog] = useState(false);
    const [nodes, setNodes, onNodesChange] = useNodesState([]);
    const [edges, setEdges, onEdgesChange] = useEdgesState([]);
    const [currentProject, setCurrentProject] = useState({});
    const [currentNode, setCurrentNode] = useState(null);
    const [currentNodeId, setCurrentNodeId] = useState(null);

    const subHeight = {
        xs: '40vh',
        sm: '50vh',
        md: '60vh',
        lg: '75vh',
        xl: '77vh',
    }

    //Quiz Values
    const [currentResponse, setCurrentResponse] = React.useState(null);
    const [answers, setAnswers] = useState({});
    const [currentQuestion, setCurrentQuestion] = React.useState(0);

    const handleChange = (event) => {
        const value = event.target.value;
        setAnswers((prev) => ({
            ...prev,
            [currentQuestion]: value,
        }));
    };

    const showSnackbar = (message, severity = "info") => {
        setSnackbar({ open: true, message, severity })
    }

    const handleCloseSnackbar = () => {
        setSnackbar({ ...snackbar, open: false })
    }


    const loadWorkflow = () => {
        setOpenLoadDialog(true); // Open the load dialog
    }

    const handleClose = () => {
        setOpenSaveDialog(false);
        setOpenLoadDialog(false);
    }

    const startWorkflow = () => {
        // You can add your workflow execution logic here
        if (!nodes || nodes.length === 0 || !edges || edges.length === 0) {
            showSnackbar("No workflow loaded. Please load a workflow first.", "error");
            return;
        }

        const startNode = nodes.find((n) => n.type === 'start');
        const nextEdge = edges.find((e) => e.source === startNode.id);
        const lessonNode = nodes.find((n) => n.id === nextEdge.target);
        setCurrentNode(lessonNode);
        setCurrentNodeId(lessonNode.id);
    }

    const handleNextNode = () => {
        const outgoingEdge = edges.find(e => e.source === currentNodeId);
        if (!outgoingEdge) return;
        const nextNode = nodes.find(n => n.id === outgoingEdge.target);
        setCurrentNode(nextNode);
        setCurrentNodeId(outgoingEdge.target);
    };

    const handleQuizSubmit = (result) => {
        // Optional: validate answer, score, or store it
        handleNextNode();
    };

    const handleRestart = () => {
        // Reset current node to the first node (typically the lesson node after 'start')
        const startNode = nodes.find((n) => n.type === 'start');
        const nextEdge = edges.find((e) => e.source === startNode.id);
        const firstNode = nodes.find((n) => n.id === nextEdge.target);
        if (firstNode) {
            setCurrentNode(firstNode);
            setCurrentNodeId(firstNode.id);
        }

        // Optionally reset other states if needed
        setCurrentResponse(null);
        setCurrentQuestion(0);
    };

    function SimulationRenderer({ currentNode }) {
        //console.log("Rendering current node:", currentNode);
        if (!currentNode) return <DefaultRender project={currentProject} onStart={startWorkflow} onLoad={loadWorkflow} subHeight={subHeight} />;

        //console.log("Node Valid:", !isNodeValid(currentNode));
        if (!isNodeValid(currentNode)) {
            return <ErrorScreen subHeight={subHeight} />;
        }

        switch (currentNode.type) {
            case 'lesson':
                return <LessonPlayer node={currentNode} subHeight={subHeight} />;
            case 'quiz':
                return <QuizSim currentQuestion={currentQuestion} setCurrentQuestion={setCurrentQuestion} handleChange={handleChange} answers={answers} setAnswers={setAnswers} node={currentNode} onComplete={handleQuizSubmit} subHeight={subHeight} currentResponse={currentResponse} setCurrentResponse={setCurrentResponse} />;
            case 'decision':
                return //<DecisionPrompt node={currentNode} onChoose={handleNextNode} />;
            case 'end':
                return <CongratulationsScreen user={user} currentProject={currentProject} onContinue={loadWorkflow} onRetry={handleRestart} subHeight={subHeight} />;
            default:
                return <DefaultRender project={currentProject} onStart={startWorkflow} onLoad={loadWorkflow} subHeight={subHeight} />;
        }
    }

    function isNodeValid(node) {
        if (!node || !node.type || !node.data) return false;

        if (node.type === 'lesson' && !node.data.content) return false;
        if (node.type === 'quiz' && (!Array.isArray(node.data.questions) || node.data.questions.length === 0)) return false;
        if (node.type === 'decision' && (!Array.isArray(node.data.options) || node.data.options.length === 0)) return false;

        return true;
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

                    {currentNode && currentNode !== undefined && currentNode.type !== 'start' ? (
                        <AnimatedButton
                            color="green"
                            reverse={true}
                            borderRadius="50px"
                            hoverTextColor="white"
                            reverseHoverColor="green"
                            size="large"
                            text="Continue"
                            border="3px solid green"
                            fullWidth={false}
                            endIcon={<ArrowForward />}
                            onclick={handleNextNode}
                        />
                    ) : (
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
                            onclick={startWorkflow}
                        />
                    )}
                </Box>
            </Grid>

            <Grid size={12}>
                <SimulationRenderer currentNode={currentNode} />
                {/*<CoursePageElement
                    data={data}
                    courseLoading={courseLoading}
                    user={user}
                />*/}
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
                setCurrentNode={setCurrentNode}
            />

            <Snackbar
                open={snackbar.open}
                autoHideDuration={6000}
                onClose={handleCloseSnackbar}
                anchorOrigin={{ vertical: "bottom", horizontal: "center" }}
            >
                <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} sx={{ width: "100%" }}>
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </Grid>
    );
}
