'use client'
import {
    Dialog, DialogTitle, DialogContent, DialogActions,
    Button, TextField, List, ListItem, ListItemText, Box,
    Typography,
    IconButton,
} from "@mui/material"
import { useEffect, useState } from "react"

import { Download } from "@mui/icons-material"

export default function LoadDialog({
    open, onClose,
    nodes, edges,
    setNodes, setEdges,
    setCurrentProject = () => { },
    setCurrentNode = () => { },
    user,
    showSnackbar,
}) {
    const [existingProjects, setExistingProjects] = useState([])
    const [templates, setTemplates] = useState([]);

    useEffect(() => {

        const fetchProjects = async (user) => {
            const userId = user.id
            const response = await fetch(`/api/getUserProjects?userId=${userId}`);
            const resp = await response.json();
            console.log("Fetching projects:", resp);

            if (!response.ok) {
                console.error("Error fetching projects:", response.statusText)
            } else {
                const { projects } = resp;
                setExistingProjects(projects || [])
            }
        }

        // Fetch projects only if user is available and dialog is open
        if (user && open) {
            fetchProjects(user)
        }
    }, [user, open])

    const handleImport = async (projectId) => {
        console.log("Loading project with ID:", projectId);
        try {
            const response = await fetch(`/api/getUserProject?projectId=${projectId}`);
            const resp = await response.json();
            console.log("Response from loading project:", resp);

            if (!response.ok) {
                console.error("Error loading project:", response.statusText);
                showSnackbar("Error Loading Project", "error");
            } else {
                setCurrentProject(resp.project);
                setCurrentNode(resp.project.nodes[0] || null); // Set first node as current if exists
                const { nodes: loadedNodes, edges: loadedEdges } = resp.project;
                console.log("Loaded nodes:", loadedNodes);
                setNodes(loadedNodes);
                setEdges(loadedEdges);
                showSnackbar("Project Loaded Successfully", "success");
                onClose();
            }
        } catch (error) {
            console.error("Error in handleImport:", error);
            showSnackbar("Error Loading Project", "error");
        }
    }

    const getTemplates = async () => {
        try {
            const response = await fetch('/api/getProjectTemplates');
            const resp = await response.json();
            console.log("Templates fetched:", resp);

            if (!response.ok) {
                console.error("Error fetching templates:", response.statusText);
                showSnackbar("Error Fetching Templates", "error");
            } else {
                // Handle templates data
                console.log("Templates data:", resp.templates);
                setTemplates(resp.templates || []);
            }
        } catch (error) {
            console.error("Error in getTemplates:", error);
            showSnackbar("Error Fetching Templates", "error");
        }
    }

    return (
        <Dialog
            open={open}
            onClose={onClose}
            fullWidth
            maxWidth="md"
            sx={{
                p: 2,
                zIndex: 5000,
            }}
        >
            <DialogTitle>
                <Box
                    sx={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                    }}
                >
                    <Typography
                        sx={{
                            textAlign: 'left',
                            fontFamily: 'Poppins',
                            fontWeight: 700,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '1vw',
                            },
                            color: "black",
                            textDecoration: 'underline',
                        }}
                    >
                        Saved Scenarios
                    </Typography>
                    <Button
                        variant="contained"
                        onClick={getTemplates}
                        color="info"
                    >
                        Get Templates
                    </Button>
                </Box>
            </DialogTitle>

            <DialogContent>

                <Box
                    sx={{
                        mb: 1,
                        display: 'flex',
                        flexDirection: 'column',
                        gap: 2,
                    }}
                >
                    {existingProjects.length > 0 ? (
                        <List dense>
                            {existingProjects.map((proj) => (
                                <Box
                                    key={proj.id}
                                    sx={{
                                        mb: 1,
                                        border: '2px solid #e0e0e0',
                                        borderRadius: '4px',
                                        backgroundColor: '#f9f9f9',
                                    }}
                                >
                                    <ListItem
                                        key={proj.id}
                                        secondaryAction={
                                            <IconButton
                                                edge="end"
                                                onClick={() => handleImport(proj.id)}
                                                title="Import Saved Project"
                                                color="info"
                                            >
                                                <Download />
                                            </IconButton>
                                        }
                                        button
                                    >
                                        <ListItemText
                                            primary={proj.name}
                                            secondary={`Description: ${proj.description}`}
                                        />
                                    </ListItem>
                                </Box>
                            ))}
                        </List>
                    ) : (
                        <Box sx={{ mt: 2, color: 'text.secondary' }}>
                            No previously saved projects found.
                        </Box>
                    )}

                    {templates.length > 0 && (
                        <>
                            <Typography
                                sx={{
                                    textAlign: 'left',
                                    fontFamily: 'Poppins',
                                    fontWeight: 700,
                                    fontSize: {
                                        xs: '1.1vw',
                                        sm: '1.2vw',
                                        md: '1.3vw',
                                        lg: '1.4vw',
                                        xl: '1vw',
                                    },
                                    color: "black",
                                    textDecoration: 'underline',
                                }}
                            >
                                Templates
                            </Typography>
                            <List dense>
                                {templates.map((template) => (
                                    <Box
                                        key={template.id}
                                        sx={{
                                            mb: 1,
                                            border: '2px solid #e0e0e0',
                                            borderRadius: '4px',
                                            backgroundColor: '#f9f9f9',
                                        }}
                                    >
                                        <ListItem
                                            key={template.id}
                                            secondaryAction={
                                                <IconButton
                                                    edge="end"
                                                    onClick={() => handleImport(template.id)}
                                                    title="Import Saved Project"
                                                    color="info"
                                                >
                                                    <Download />
                                                </IconButton>
                                            }
                                            button
                                        >
                                            <ListItemText
                                                primary={template.name}
                                                secondary={`Description: ${template.description}`}
                                            />
                                        </ListItem>
                                    </Box>
                                ))}
                            </List>
                        </>
                    )}
                </Box>

            </DialogContent>

            <DialogActions>
                <Button onClick={onClose} color="error">Cancel</Button>
                {/*<Button onClick={handleSave} color="success" variant="contained">Save</Button>*/}
            </DialogActions>
        </Dialog>
    )
}
