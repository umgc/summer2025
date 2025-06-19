import {
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Button,
    TextField,
    Select,
    MenuItem,
    FormControl,
    InputLabel,
    IconButton,
    Box,
    Typography,
} from "@mui/material";
import { useState, useEffect } from "react";
import { Delete } from "@mui/icons-material";

export default function QuizInput({ localData, handleChange }) {
    const parsedQuestions = Array.isArray(localData.questions)
        ? localData.questions
        : [];

    const [questions, setQuestions] = useState(parsedQuestions);
    const [dialogOpen, setDialogOpen] = useState(false);
    const [editing, setEditing] = useState(null); // null for new, index for editing
    const [questionData, setQuestionData] = useState({
        type: "multiple",
        question: "",
        options: [""],
        answer: "",
    });
    const [errors, setErrors] = useState({
        question: false,
        options: false,
        answer: false,
        text: "",
    });

    useEffect(() => {
        handleChange("questions", questions);
        setErrors({
            question: false,
            options: false,
            answer: false,
            text: "",
        });
    }, [questions]);

    const openNewDialog = () => {
        setQuestionData({ type: "multiple", question: "", options: [""], answer: "" });
        setEditing(null);
        setDialogOpen(true);
    };

    const saveQuestion = () => {
        const isDuplicate = questions.some(
            (q) => q.question.trim().toLowerCase() === questionData.question.trim().toLowerCase()
        );

        if (isDuplicate) {
            setErrors((prev) => ({
                ...prev,
                question: true,
                text: "A question with this title already exists.",
            }));
            return;
        }

        if (editing !== null) {
            const updated = [...questions];
            updated[editing] = questionData;
            setQuestions(updated);
        } else {
            setQuestions([...questions, questionData]);
        }
        setDialogOpen(false);
    };

    const deleteQuestion = (index) => {
        const updated = [...questions];
        updated.splice(index, 1);
        setQuestions(updated);
    };

    const renderDialogFields = () => {
        return (
            <Box
                sx={{
                    p: 1,
                }}
            >
                <FormControl fullWidth sx={{ mb: 2 }}>
                    <InputLabel>Type</InputLabel>
                    <Select
                        value={questionData.type}
                        label="Type"
                        onChange={(e) => setQuestionData({ ...questionData, type: e.target.value })}
                        MenuProps={{ disablePortal: true }}
                    >
                        <MenuItem value="multiple">Multiple Choice</MenuItem>
                        <MenuItem value="truefalse">True / False</MenuItem>
                        <MenuItem value="short">Short Answer</MenuItem>
                    </Select>
                </FormControl>

                <TextField
                    fullWidth
                    label="Question"
                    value={questionData.question}
                    onChange={(e) => setQuestionData({ ...questionData, question: e.target.value })}
                    sx={{ mb: 2 }}
                    error={errors.question}
                    helperText={errors.question ? errors.text : ""}
                />

                {questionData.type === "multiple" && (
                    <>
                        {questionData.options.map((opt, i) => (
                            <Box key={i} sx={{ display: "flex", mb: 1 }}>
                                <TextField
                                    fullWidth
                                    label={`Option ${i + 1}`}
                                    value={opt}
                                    onChange={(e) => {
                                        const newOpts = [...questionData.options];
                                        newOpts[i] = e.target.value;
                                        setQuestionData({ ...questionData, options: newOpts });
                                    }}
                                />
                                <IconButton
                                    onClick={() => {
                                        const newOpts = [...questionData.options];
                                        newOpts.splice(i, 1);
                                        setQuestionData({ ...questionData, options: newOpts });
                                    }}
                                >
                                    <Delete />
                                </IconButton>
                            </Box>
                        ))}
                        <Button
                            size="small"
                            onClick={() => setQuestionData({ ...questionData, options: [...questionData.options, ""] })}
                        >
                            Add Option
                        </Button>
                    </>
                )}

                <TextField
                    fullWidth
                    label={questionData.type === "truefalse" ? "Answer (true/false)" : "Answer"}
                    value={questionData.answer}
                    onChange={(e) => setQuestionData({ ...questionData, answer: e.target.value })}
                    sx={{ mt: 2 }}
                />
            </Box>
        );
    };

    return (
        <>
            <TextField
                fullWidth
                label="Quiz Title"
                value={localData.title || ""}
                onChange={(e) => handleChange("title", e.target.value)}
                sx={{ mb: 2 }}
            />
            <TextField
                fullWidth
                type="number"
                label="Passing Score (%)"
                value={localData.passingScore || ""}
                onChange={(e) => handleChange("passingScore", e.target.value)}
                sx={{ mb: 2 }}
            />
            <TextField
                fullWidth
                type="number"
                label="Time Limit (minutes)"
                value={localData.timeLimit || ""}
                onChange={(e) => handleChange("timeLimit", e.target.value)}
                sx={{ mb: 2 }}
            />

            <Typography
                variant="subtitle1"
                sx={{
                    mt: 2,
                    mb: 1,
                    textDecoration: "underline",
                    textAlign: "center",
                }}
            >
                Questions
            </Typography>

            {questions.map((q, i) => (
                <Box key={i} sx={{ mb: 1, display: "flex", justifyContent: "space-between" }}>
                    <Typography variant="body2">{q.question}</Typography>
                    <Box>
                        <Button size="small" onClick={() => { setEditing(i); setQuestionData(q); setDialogOpen(true); }}>
                            Edit
                        </Button>
                        <Button size="small" color="error" onClick={() => deleteQuestion(i)}>
                            Delete
                        </Button>
                    </Box>
                </Box>
            ))}

            <Button
                variant="outlined"
                onClick={openNewDialog}
                sx={{
                    mt: 2,
                    textAlign: "center",
                    display: "flex",
                    width: "100%",
                    alignItems: "center",
                    justifyContent: "center",
                }}
            >
                Add Question
            </Button>

            <Dialog
                open={dialogOpen}
                onClose={() => setDialogOpen(false)}
                fullWidth
                maxWidth="lg"
                sx={{
                    zIndex: 5300, // Ensure dialog is above other elements
                }}
            >
                <DialogTitle>{editing !== null ? "Edit Question" : "Add New Question"}</DialogTitle>
                <DialogContent>{renderDialogFields()}</DialogContent>
                <DialogActions>
                    <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
                    <Button onClick={saveQuestion} variant="contained">Save</Button>
                </DialogActions>
            </Dialog>
        </>
    );
}
