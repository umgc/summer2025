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
    user,
    showSnackbar,
}) {
    const [existingProjects, setExistingProjects] = useState([])

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
                    Saved Simulations
                </Typography>
            </DialogTitle>

            <DialogContent>

                <Box sx={{ mb: 1 }}>


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
                </Box>

            </DialogContent>

            <DialogActions>
                <Button onClick={onClose} color="error">Cancel</Button>
                {/*<Button onClick={handleSave} color="success" variant="contained">Save</Button>*/}
            </DialogActions>
        </Dialog>
    )
}
