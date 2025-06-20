"use client"
import * as React from "react"
import {
    Box,
    Typography,
    Paper,
    Tabs,
    Tab,
    Divider,
    useMediaQuery,
    IconButton,
    Grid,
    Avatar,
    Button,
} from "@mui/material"


// Custom Components
import QuestionsCard from "./questionCard"
import AnimatedButton from "@/app/GlobalComponents/AnimatedButtonDialog"
import { ArrowBack } from "@mui/icons-material"

export default function QuestionsTab({ data, courseLoading, user }) {

    const [selectedQuestion, setSelectedQuestion] = React.useState(null);
    const [questions, setQuestions] = React.useState(data?.questions || []);

    React.useEffect(() => {
        if (data?.questions) {
            setQuestions(data.questions);
        }
    }, [data, data.questions]);

    const handleUpvote = async (question) => {

        const resp = await fetch('/api/upvote-question', {
            method: 'POST',
            body: JSON.stringify({ question, user }),
            headers: { 'Content-Type': 'application/json' }
        });
        const result = await resp.json();

        if (result.success) {
            // Update the question state to reflect the upvote
            setQuestions(prevQuestions =>
                prevQuestions.map(q => {
                    if (q.id === question.id) {
                        return {
                            ...q,
                            course_votes: [...q.course_votes, result.vote]  // append new vote
                        };
                    }
                    return q;
                })
            );
        }
        return;
    }

    const handleDownvote = async (question) => {

        const resp = await fetch('/api/downvote-question', {
            method: 'POST',
            body: JSON.stringify({ question, user }),
            headers: { 'Content-Type': 'application/json' }
        });
        const result = await resp.json();

        if (result.success) {
            setQuestions(prevQuestions =>
                prevQuestions.map(q =>
                    q.id === question.id
                        ? {
                            ...q,
                            course_votes: q.course_votes.filter(v => v?.user_id !== user.id)
                        }
                        : q
                )
            );
        }
    };


    if (selectedQuestion !== null) {
        return (
            <Box
                sx={{
                    maxWidth: {
                        xs: "100%",
                        sm: "100%",
                        md: "100%",
                        lg: "100%",
                        xl: "50vw",
                    },  // Or "md", or a fixed px like 960
                    mx: "auto",         // Centers it horizontally
                    pt: 3,
                    pb: 5,
                    px: 2,
                    display: "flex",
                    flexDirection: "column",
                    gap: 3,
                }}
            >
                <Box
                    sx={{
                        display: "flex",
                        flexDirection: "column",
                        //justifyContent: "flex-start",
                        gap: 2,
                        width: "fit-content",
                    }}
                >
                    <AnimatedButton
                        color="#87CEEB"
                        reverse={true}
                        borderRadius="5px"
                        hoverTextColor="black"
                        reverseHoverColor="black"
                        size="medium"
                        text="Back to Questions"
                        border="3px solid #87CEEB"
                        startIcon={<ArrowBack />}
                        onclick={() => setSelectedQuestion(null)}
                    />
                </Box>

                <QuestionsCard
                    index="0"
                    question={selectedQuestion}
                    setSelectedQuestion={setSelectedQuestion}
                    handleUpvote={handleUpvote}
                    handleDownvote={handleDownvote}
                    user={user}
                />

                <Typography
                    sx={{
                        textAlign: "left",
                        fontSize: {
                            xs: '8vw',
                            sm: '4vw',
                            md: '3vw',
                            lg: '1vw',
                            xl: '.8vw',
                        },
                        fontFamily: 'Poppins',
                        fontWeight: 500,
                        color: "black",
                        lineHeight: 1,
                        mb: -1,
                    }}
                >
                    {selectedQuestion?.course_answers?.length || 0} Replies
                </Typography>
                <Divider sx={{ my: 0, borderColor: "gray" }} />

                <Box
                    sx={{
                        px: 3,
                    }}
                >
                    {selectedQuestion?.course_answers.map((answer, index) => (
                        <Box>
                            <QuestionsCard
                                index={index}
                                question={answer}
                                setSelectedQuestion={null}
                                handleUpvote={handleUpvote}
                                handleDownvote={handleDownvote}
                                user={user}
                            />
                            {/*<Divider sx={{ my: 1, borderColor: "gray" }} />*/}
                        </Box>
                    ))}
                </Box>
            </Box>
        )
    } else {
        return (
            <Box
                sx={{
                    maxWidth: {
                        xs: "100%",
                        sm: "100%",
                        md: "100%",
                        lg: "100%",
                        xl: "50vw",
                    },  // Or "md", or a fixed px like 960
                    mx: "auto",         // Centers it horizontally
                    pt: 3,
                    pb: 5,
                    px: 2               // Some padding for smaller screens
                }}
            >
                <Typography
                    sx={{
                        textAlign: "left",
                        fontSize: {
                            xs: '8vw',
                            sm: '4vw',
                            md: '3vw',
                            lg: '2vw',
                            xl: '1vw',
                        },
                        fontFamily: 'Poppins',
                        fontWeight: 600,
                        color: "black",
                    }}
                >
                    All questions in this course ({data?.questions?.length || 0})
                </Typography>

                <Divider sx={{ my: 2, borderColor: "black" }} />

                {questions.map((question, index) => (
                    <Box>
                        <QuestionsCard
                            index={index}
                            question={question}
                            setSelectedQuestion={setSelectedQuestion}
                            handleUpvote={handleUpvote}
                            handleDownvote={handleDownvote}
                            user={user}
                        />
                        <Divider sx={{ my: 1, borderColor: "gray" }} />
                    </Box>
                ))}
            </Box>
        )
    }
}