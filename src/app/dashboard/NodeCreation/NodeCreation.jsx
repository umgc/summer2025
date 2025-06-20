'use client';
import React, { useState, useEffect, useRef } from 'react';
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
import SaveDialog from './SaveDialog/SaveDialog';
import LoadDialog from './LoadDialog/LoadDialog';

export default function NodeCreation({
    user,
}) {

    const [nodes, setNodes, onNodesChange] = useNodesState([]);
    const [edges, setEdges, onEdgesChange] = useEdgesState([]);
    const [snackbar, setSnackbar] = useState({ open: false, message: "", severity: "info" })
    const [openSaveDialog, setOpenSaveDialog] = useState(false);
    const [openLoadDialog, setOpenLoadDialog] = useState(false);
    const [currentNodeId, setCurrentNodeId] = useState(null);

    //Loading
    const [executeLoading, setExecuteLoading] = useState(false);

    useEffect(() => {
        setNodes((prevNodes) =>
            prevNodes.map((node) => ({
                ...node,
                style: {
                    ...node.style,
                    transition: 'all 0.3s ease',
                    border: node.id === currentNodeId ? '4px solid #00bcd4' : '1px solid #ccc',
                    boxShadow: node.id === currentNodeId ? '0 0 15px #00bcd4' : 'none',
                    backgroundColor: node.id === currentNodeId ? '#00bcd4' : 'white',
                    borderRadius: '5px',
                },
            }))
        );
    }, [currentNodeId, setNodes]);



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

        setOpenSaveDialog(true); // Open the save dialog

        //showSnackbar("Your workflow has been saved successfully", "success")
    }

    const loadWorkflow = () => {
        setOpenLoadDialog(true); // Open the load dialog
    }

    const executeWorkflow = async () => {
        if (nodes.length === 0) {
            showSnackbar("Add some nodes to your workflow first", "error");
            return;
        }

        setExecuteLoading(true);
        setCurrentNodeId(null); // reset previous highlight

        // Clear all previous highlights
        setNodes((prevNodes) =>
            prevNodes.map((node) => ({
                ...node,
                style: {
                    ...node.style,
                    transition: 'all 0.3s ease',
                    border: '1px solid #ccc',
                    boxShadow: 'none',
                    backgroundColor: 'white',
                },
            }))
        );

        try {
            let currentNode = nodes.find((n) => n.type === 'start');

            while (currentNode) {
                setCurrentNodeId(currentNode.id);

                if (currentNode.type === 'start' || currentNode.type === 'end') {
                    await new Promise((res) => setTimeout(res, 1000)); // pause 1s
                }

                if (currentNode.type === 'quiz') {
                    const result = await simulateNode(currentNode);

                    const correctAnswer = currentNode.data.questions[0]?.answer;
                    const match = result.match(/\*\*Answer:\s*(.*?)\*\*/i);
                    const aiAnswer = match ? match[1].trim() : null;
                    showSnackbar(`Simulated Student Answer: ${aiAnswer}`, "warning");
                    const correct = aiAnswer?.toLowerCase() === correctAnswer.toLowerCase();

                    const expectedLabel = correct ? 'pass' : 'fail';
                    const nextEdge = edges.find((e) =>
                        e.source === currentNode.id &&
                        e.label?.toLowerCase().includes(expectedLabel)
                    );

                    if (!nextEdge) {
                        console.warn(`No '${expectedLabel}' edge found for node ${currentNode.id}`);
                        break; // stops traversal, prevents undefined errors
                    }

                    currentNode = nodes.find((n) => n.id === nextEdge.target);

                } else {
                    const nextEdge = edges.find((e) => e.source === currentNode.id);
                    currentNode = nodes.find((n) => n.id === nextEdge?.target);
                }

                if (currentNode?.type !== 'end') {
                    await new Promise((res) => setTimeout(res, 1000)); // optional visual delay between nodes
                }
            }

            showSnackbar("Scenario complete", "success");
        } catch (error) {
            console.error("Execution failed:", error);
            showSnackbar("Scenario failed", "error");
        } finally {
            console.log("Execution finished");
            setExecuteLoading(false);
            //setCurrentNodeId(null);
        }
    };



    const handleClose = () => {
        setOpenSaveDialog(false);
        setOpenLoadDialog(false);
    }

    const simulateNode = async (node) => {
        console.log("Simulating node:", node);
        try {
            setCurrentNodeId(node.id);
            const res = await fetch('/api/simulateNode', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ node }),
            });
            console.log("Scenario response:", res);

            if (!res.ok) {
                throw new Error("Scenario failed");
            }

            const reader = res.body?.getReader();
            const decoder = new TextDecoder();
            let text = '';

            while (true) {
                const { done, value } = await reader.read();
                if (done) {
                    text += decoder.decode(); // flush final text
                    break;
                }
                text += decoder.decode(value, { stream: true });
            }

            console.log("Simulated result:", text);
            return text;
        } catch (err) {
            console.error(err);
            showSnackbar("Scenario failed", "error");
            setExecuteLoading(false);
        }
        setCurrentNodeId(null);
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
                    Scenario Designer
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
                        text="Simulate"
                        border="3px solid #87CEEB"
                        fullWidth={false}
                        endIcon={<PlayArrow />}
                        onclick={executeWorkflow}
                        loading={executeLoading}
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

            <SaveDialog
                open={openSaveDialog}
                onClose={handleClose}
                user={user}
                nodes={nodes}
                edges={edges}
                showSnackbar={showSnackbar}
            />

            <LoadDialog
                open={openLoadDialog}
                onClose={handleClose}
                user={user}
                nodes={nodes}
                edges={edges}
                setEdges={setEdges}
                setNodes={setNodes}
                showSnackbar={showSnackbar}
            />

        </Grid>
    );
}
