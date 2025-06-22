'use client';
import React, { useState } from 'react';
import {
    Box,
    Grid,
    Typography,
    Button,
    TextField,
    RadioGroup,
    FormControlLabel,
    Radio,
} from '@mui/material';
import { ArrowForward } from '@mui/icons-material';

//Custom Components
import ResponseSection from './ResponseSection';

export default function QuizSim({
    node, onComplete, subHeight,
    currentResponse, setCurrentResponse,
    showSnackbar,
    //answers, setAnswers, handleChange, 
    currentQuestion, setCurrentQuestion,
}) {

    //const [currentQuestion, setCurrentQuestion] = useState(0);
    const [executeLoading, setExecuteLoading] = React.useState(false);
    const [answers, setAnswers] = useState({});

    const handleChange = (event) => {
        const value = event.target.value;
        setAnswers((prev) => ({
            ...prev,
            [currentQuestion]: value,
        }));
    };

    const handleSubmit = async () => {
        try {
            setExecuteLoading(true);
            const type = node.data.questions[currentQuestion].type;
            const currQuestion = node.data.questions[currentQuestion].question;
            const currAnswer = answers[currentQuestion];
            console.log("Submitting answer:", currAnswer);
            if (type === 'short') {
                const result = await evaluateAnswer(currQuestion, currAnswer);
                const { verdict, reason } = parseDeepSeekResponse(result);
                setCurrentResponse({ verdict, reason });
            } else if (type === 'multiple') {
                const result = await evaluateMultipleChoice(currQuestion, currAnswer);
                setCurrentResponse(result);
            }
            setExecuteLoading(false);
        } catch (err) {
            console.error("Error during question submission:", err);
            setExecuteLoading(false);
            showSnackbar("Error submitting answer", "error");
        }
    }

    const handleNext = () => {
        setCurrentResponse(null); // Reset response for next question
        //setAnswers({})
        
        if (currentQuestion + 1 < node.data.questions.length) {
            setCurrentQuestion(currentQuestion + 1);
        } else {
            onComplete?.(answers); // Send answers back to parent
        }
    };

    // Function to evaluate short answer using the backend DeepSeek API
    const evaluateAnswer = async (currQuestion, currAnswer) => {
        try {
            const res = await fetch('/api/quizShortAnswer', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ currQuestion, currAnswer }),
            });

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

            return text;
        } catch (err) {
            console.error(err);
            showSnackbar("Eval Answer failed", "error");
            setExecuteLoading(false);
        }
        setCurrentNodeId(null);
    }

    const evaluateMultipleChoice = async (currQuestion, currAnswer) => {
        const correctAnswer = node.data.questions[currentQuestion].answer;
        console.log("Correct Answer:", node.data.questions[currentQuestion]);
        console.log("User Answer:", currAnswer);
        const isCorrect = currAnswer.trim().toLowerCase() === correctAnswer.trim().toLowerCase();

        return {
            verdict: isCorrect ? "Correct" : "Incorrect",
            reason: isCorrect
                ? "Your answer matches the correct option."
                : `The correct answer was "${correctAnswer}", but you selected "${currAnswer}".`
        };
    };


    function parseDeepSeekResponse(responseText) {
        const verdictMatch = responseText.match(/Verdict:\s*(Correct|Incorrect)/i);
        const reasonMatch = responseText.match(/Reason:\s*(.+)/i);

        const verdict = verdictMatch ? verdictMatch[1] : null;
        const reason = reasonMatch ? reasonMatch[1].trim() : null;

        return { verdict, reason };
    }

    return (
        <Box
            sx={{
                position: 'relative',
                zIndex: 1,
                width: '100%',
                height: subHeight,
                display: 'flex',
                flexDirection: 'row',
                justifyContent: 'center',
                alignItems: 'center',
                gap: 3,
            }}
        >
            <Grid
                container
                spacing={2}
                sx={{
                    position: 'absolute',
                    top: '50%',
                    left: '50%',
                    transform: 'translate(-50%, -50%)',
                    zIndex: 2,
                    backgroundColor: '#f4f6f6',
                    borderRadius: "20px",
                    boxShadow: 10,
                    p: 3,
                }}
            >
                <Grid size={12}>
                    <Typography
                        sx={{
                            textAlign: "left",
                            color: "info.main",
                            lineHeight: 1,
                            fontWeight: 600,
                            fontFamily: 'Poppins',
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '1.25rem',
                            },
                        }}
                    >
                        Questions {currentQuestion + 1} of {node.data.questions.length}
                    </Typography>
                </Grid>

                <Grid size={12}>
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
                                xl: '2rem',
                            },
                        }}
                    >
                        {node.data.questions[currentQuestion].question}
                    </Typography>
                </Grid>

                {/* Render options for the current question */}
                <Grid size={12}>
                    {node.data.questions[currentQuestion].type === 'short' && (
                        <TextField
                            //key={`short-answer-${currentQuestion}`}
                            fullWidth
                            multiline
                            rows={10}
                            label="Your answer"
                            value={answers[currentQuestion] || ''}  // ✅ single source of truth
                            onChange={handleChange}
                        />
                    )}

                    {node.data.questions[currentQuestion].type === 'multiple' && (
                        <RadioGroup
                            value={answers[currentQuestion] || ''}
                            onChange={handleChange}
                        >
                            {node.data.questions[currentQuestion].options.map((option, idx) => (
                                <FormControlLabel
                                    key={idx}
                                    value={option}
                                    control={<Radio />}
                                    label={option}
                                />
                            ))}
                        </RadioGroup>
                    )}
                </Grid>

                {currentResponse && currentResponse !== null && (
                    <Box>
                        <Grid size={12} sx={{ mb: 0 }}>
                            <Typography
                                sx={{
                                    textAlign: "left",
                                    color: currentResponse.verdict === "Correct" ? "green" : "red",
                                    lineHeight: 1,
                                    fontWeight: 600,
                                    fontFamily: 'Poppins',
                                    fontSize: {
                                        xs: '1.1vw',
                                        sm: '1.2vw',
                                        md: '1.3vw',
                                        lg: '1.4vw',
                                        xl: '1.5rem',
                                    },
                                }}
                            >
                                {currentResponse.verdict ? currentResponse.verdict : "Error: No verdict provided"}
                            </Typography>
                        </Grid>

                        <Grid size={12}>
                            <Typography
                                sx={{
                                    textAlign: "left",
                                    color: "black",
                                    lineHeight: 1.3,
                                    fontWeight: 600,
                                    fontFamily: 'Poppins',
                                    fontSize: {
                                        xs: '1.1vw',
                                        sm: '1.2vw',
                                        md: '1.3vw',
                                        lg: '1.4vw',
                                        xl: '1.25rem',
                                    },
                                }}
                            >
                                {currentResponse.reason ? currentResponse.reason : "No reason provided"}
                            </Typography>
                        </Grid>
                    </Box>
                )}

                <Grid size={12}>
                    <Box
                        sx={{
                            display: 'flex',
                            justifyContent: 'flex-end',
                            alignItems: 'center',
                        }}
                    >
                        {currentResponse && currentResponse !== null ? (
                            <Button
                                variant="contained"
                                onClick={handleNext}
                                color="info"
                                endIcon={<ArrowForward />}
                            >
                                {currentQuestion + 1 === node.data.questions.length ? 'Next Section' : 'Next Question'}
                            </Button>
                        ) : (
                            <Button
                                variant="contained"
                                onClick={handleSubmit}
                                color="success"
                                loading={executeLoading}
                            >
                                {currentQuestion + 1 === node.data.questions.length ? 'Submit' : 'Submit'}
                            </Button>
                        )}

                    </Box>
                </Grid>
            </Grid>

            {/*currentResponse && currentResponse !== null && (
                <ResponseSection
                    verdict={currentResponse ? currentResponse.verdict : "Unknown"}
                    reason={currentResponse ? currentResponse.reason : "No reason provided"}
                />
            )*/}
        </Box >
    );
}
