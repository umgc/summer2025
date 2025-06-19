'use client'
import {
    Dialog, DialogTitle, DialogContent, DialogActions,
    Button, TextField, List, ListItem, ListItemText, Box,
    Typography,
    IconButton,
} from "@mui/material"
import { useEffect, useState } from "react"

import { Save } from "@mui/icons-material"

export default function SaveDialog({
    open, onClose, userId, nodes, edges, user,
    showSnackbar,
}) {
    const [name, setName] = useState("")
    const [description, setDescription] = useState("")
    const [existingProjects, setExistingProjects] = useState([])

    useEffect(() => {

        const fetchProjects = async (user) => {
            const userId = user.id
            const response = await fetch(`/api/getUserProjects?userId=${userId}`);
            //console.log("Fetching projects:", response);

            if (!response.ok) {
                console.error("Error fetching projects:", response.statusText)
            } else {
                const { projects } = await response.json();
                setExistingProjects(projects || [])
            }
        }

        if (user && open) {
            fetchProjects(user)
        }
    }, [userId, open])

    const handleSave = async () => {
        if (!name) return alert("Project name is required")

        try {
            const response = await fetch('/api/postUserProject', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    user_id: user.id,
                    name,
                    description,
                    nodes,
                    edges,
                }),
            });
            const resp = await response.json();
            console.log("Save response:", resp);

            if (!response.ok) {
                console.error("Error saving project:", error);
                showSnackbar("Error Saving Project", "error")
            } else {
                showSnackbar("Your project has been saved successfully", "success")
                onClose()
            }

        } catch (error) {
            console.error("Error saving project:", error);
            showSnackbar("Error Saving Project", "error")
            return;
        }
    }

    const handleUpdateExistingProject = async (projectId) => {
        try {
            console.log("Updating project with ID:", projectId);
            const response = await fetch('/api/updateUserProject', {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    id: projectId,
                    nodes,
                    edges,
                   // name,
                  //  description,
                }),
            });

            if (!response.ok) {
                console.error("Error updating project:", await response.text());
                showSnackbar("Error Updating Project", "error");
            } else {
                showSnackbar("Project updated successfully", "success");
                onClose();
            }
        } catch (error) {
            console.error("Error updating project:", error);
            showSnackbar("Error Updating Project", "error");
        }
    };



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
            <DialogTitle>Save Your Simulation</DialogTitle>
            <DialogContent>

                <Box sx={{ mb: 1 }}>
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
                        Previously Saved Projects
                    </Typography>

                    {existingProjects.length > 0 ? (
                        <List dense>
                            {existingProjects.map((proj) => (
                                <Box
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
                                                onClick={() => handleUpdateExistingProject(proj.id)}
                                                title="Save to existing project"
                                                color="info"
                                            >
                                                <Save />
                                            </IconButton>
                                        }
                                        button
                                        onClick={() => {
                                            setName(proj.name);
                                            setDescription(proj.description);
                                        }}
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
                        mb: 1,
                    }}
                >
                    New Project Save
                </Typography>
                <TextField
                    fullWidth
                    label="Project Name"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    sx={{ mb: 2 }}
                />
                <TextField
                    fullWidth
                    label="Description"
                    multiline
                    rows={2}
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                />


            </DialogContent>

            <DialogActions>
                <Button onClick={onClose} color="error">Cancel</Button>
                <Button onClick={handleSave} color="success" variant="contained">Save</Button>
            </DialogActions>
        </Dialog>
    )
}
