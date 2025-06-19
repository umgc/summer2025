'use client';
import React, { useState, useCallback, useRef } from 'react';
import {
    Box,
    CssBaseline,
    Drawer,
    AppBar,
    Toolbar,
    Typography,
    List,
    ListItem,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    IconButton,
    Divider,
    Grid,
    Tooltip,
    Avatar,
    Button,
} from '@mui/material';
import Link from 'next/link';
import Image from 'next/image';

import {
    Menu as MenuIcon,
    Upload,
    Save,
    PlayArrow,
} from '@mui/icons-material';

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


//Custom Components
import AnimatedButton from "@/app/Buttons/AnimatedButton";
import WorkflowBuilder from './workflow-builder';

export default function NodeCreation({
    user,
}) {

    const [nodes, setNodes, onNodesChange] = useNodesState([]);
    const [edges, setEdges, onEdgesChange] = useEdgesState([]);
    const [snackbar, setSnackbar] = useState({ open: false, message: "", severity: "info" })

    const showSnackbar = (message, severity = "info") => {
        setSnackbar({ open: true, message, severity })
    }

    const handleCloseSnackbar = () => {
        setSnackbar({ ...snackbar, open: false })
    }

    const saveWorkflow = () => {
        if (nodes.length === 0) {
            showSnackbar("Add some nodes to your workflow first", "error")
            return
        }

        const workflow = {
            nodes,
            edges,
        }

        const workflowString = JSON.stringify(workflow)
        localStorage.setItem("workflow", workflowString)

        showSnackbar("Your workflow has been saved successfully", "success")
    }

    const loadWorkflow = () => {
        const savedWorkflow = localStorage.getItem("workflow")

        if (!savedWorkflow) {
            showSnackbar("There is no workflow saved in your browser", "error")
            return
        }

        try {
            const { nodes: savedNodes, edges: savedEdges } = JSON.parse(savedWorkflow)
            setNodes(savedNodes)
            setEdges(savedEdges)
            showSnackbar("Your workflow has been loaded successfully", "success")
        } catch (error) {
            showSnackbar("There was an error loading your workflow", "error")
        }
    }

    const executeWorkflow = () => {
        if (nodes.length === 0) {
            showSnackbar("Add some nodes to your workflow first", "error")
            return
        }

        showSnackbar("Your workflow is being executed (simulation only in this MVP)", "info")

        setTimeout(() => {
            showSnackbar("Your workflow has been executed successfully", "success")
        }, 2000)
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
                    Simulation Creation
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
                    Create and manage your project nodes here. Use the tools below to add, export, and manage your project data.
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
                        color="black"
                        reverse={false}
                        borderRadius="50px"
                        hoverTextColor="#87CEEB"
                        reverseHoverColor="black"
                        size="large"
                        text="Save"
                        border="3px solid #87CEEB"
                        fullWidth={false}
                        endIcon={<Save />}
                        onclick={saveWorkflow}
                    />
                    <AnimatedButton
                        color="#87CEEB"
                        reverse={true}
                        borderRadius="50px"
                        hoverTextColor="black"
                        reverseHoverColor="black"
                        size="large"
                        text="Execute"
                        border="3px solid #87CEEB"
                        fullWidth={false}
                        endIcon={<PlayArrow />}
                        onclick={executeWorkflow}
                    />
                </Box>
            </Grid>

            <Grid size={12}>
                <WorkflowBuilder
                    user={user}

                    nodes={nodes}
                    setNodes={setNodes}
                    onNodesChange={onNodesChange}

                    edges={edges}
                    setEdges={setEdges}
                    onEdgesChange={onEdgesChange}

                    snackbar={snackbar}
                    setSnackbar={setSnackbar}
                    showSnackbar={showSnackbar}
                    handleCloseSnackbar={handleCloseSnackbar}
                />
            </Grid>

        </Grid>
    );
}
