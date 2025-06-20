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

} from "@mui/material"
import {
    ArrowCircleUp, Chat,
    ThumbUp, ThumbUpOffAlt
} from "@mui/icons-material"

export default function QuestionsCard({
    question, index, setSelectedQuestion,
    handleUpvote, handleDownvote,
    user,
}) {
    const [userHasVoted, setUserHasVoted] = React.useState(false);
    const [voteCount, setVoteCount] = React.useState(question.course_votes.length || 0);
    console.log("Question votes:", question.course_votes);

    React.useEffect(() => {
        console.log("Checking user votes for question:", question.course_votes);
        if (question && question.course_votes !== undefined && question.course_votes && question.course_votes.length > 0) {
            const hasVoted = question.course_votes.some(v => v?.user_id === user.id);
            setUserHasVoted(hasVoted);
        }

        if (question && question.course_votes !== undefined && question.course_votes) {
            setVoteCount(question.course_votes.length);
        }
    }, []);

    const downvote = async (question) => {
        handleDownvote(question);
        setUserHasVoted(false);
        setVoteCount(prevCount => prevCount > 0 ? prevCount - 1 : 0); // Decrease vote count if it was greater than 0
    }

    const upvote = async (question) => {
        handleUpvote(question);
        setUserHasVoted(true);
        setVoteCount(prevCount => prevCount + 1); // Increase vote count
    }

    return (
        <Grid
            container
            key={index}
            spacing={2}
            sx={{
                display: "flex",
                flexDirection: "row",
                justifyContent: "center",
                alignItems: "flex-start",
                gap: 1,
                pb: 1,
            }}
        >
            <Grid
                size="auto"
                sx={{
                    px: 3,
                    mt: 1,
                }}
            >
                <Box
                    sx={{
                        display: "flex",
                        flexDirection: "column",
                        alignItems: "center",
                        justifyContent: "center",
                    }}
                >
                    <Avatar
                        alt={`${question.firstName} ${question.lastName?.charAt(0)} avatar`}
                        aria-label={`${question.firstName} ${question.lastName?.charAt(0)} avatar`}
                        sx={{
                            width: { xs: '20vw', sm: '8vw', md: '6vw', lg: '2vw' },
                            height: { xs: '20vw', sm: '8vw', md: '6vw', lg: '2vw' },
                            bgcolor: '#87CEEB',
                            fontSize: {
                                xs: '9vw',
                                sm: '4vw',
                                md: '3vw',
                                lg: '1.5vw',
                                xl: '1.25vw'
                            },
                        }}
                    >
                        {`${question.firstName} ${question.lastName?.charAt(0)}`.charAt(0).toUpperCase()}
                    </Avatar>
                    <Typography
                        sx={{
                            textAlign: "center",
                            fontSize: {
                                xs: '8vw',
                                sm: '4vw',
                                md: '3vw',
                                lg: '2vw',
                                xl: '.6vw',
                            },
                            fontFamily: 'Poppins',
                            fontWeight: 300,
                            color: "black",
                        }}
                    >
                        {question.firstName} {question.lastName?.charAt(0)}.
                    </Typography>
                </Box>
            </Grid>

            <Grid
                size={10}
                sx={{
                    display: "flex",
                    flexDirection: "column",
                    justifyContent: "center",
                    alignItems: "flex-start",
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
                            xl: '.5vw',
                        },
                        fontFamily: 'Poppins',
                        fontWeight: 300,
                        color: "gray",
                    }}
                >
                    Asked: {new Date(question.created_at).toLocaleDateString()}
                </Typography>

                <Typography
                    sx={{
                        textAlign: "left",
                        fontSize: {
                            xs: '8vw',
                            sm: '4vw',
                            md: '3vw',
                            lg: '2vw',
                            xl: '.9vw',
                        },
                        fontFamily: 'Poppins',
                        fontWeight: 600,
                        color: "black",
                        cursor: setSelectedQuestion === null ? 'default' : 'pointer',
                    }}
                    onClick={setSelectedQuestion ? () => setSelectedQuestion(question) : undefined}
                >
                    {question.title}
                </Typography>
                <Typography
                    sx={{
                        textAlign: "left",
                        fontSize: {
                            xs: '8vw',
                            sm: '4vw',
                            md: '3vw',
                            lg: '2vw',
                            xl: '.75vw',
                        },
                        fontFamily: 'Poppins',
                        fontWeight: 400,
                        color: "black",
                        cursor: setSelectedQuestion === null ? 'default' : 'pointer',
                    }}
                    onClick={setSelectedQuestion ? () => setSelectedQuestion(question) : undefined}
                >
                    {question.body}
                </Typography>

            </Grid>

            <Grid
                size="grow"
            >
                <Box
                    sx={{
                        display: "flex",
                        flexDirection: "column",
                        alignItems: "center",
                        justifyContent: "center",
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
                                xl: '.75vw',
                            },
                            fontFamily: 'Poppins',
                            fontWeight: 300,
                            color: "black",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                            cursor: 'pointer',
                        }}
                        onClick={() =>
                            userHasVoted ? downvote(question) : upvote(question)
                        }
                    >
                        {voteCount}
                        {userHasVoted ? (
                            <ThumbUp sx={{ color: "black", ml: 1 }} />
                        ) : (
                            <ThumbUpOffAlt sx={{ color: "black", ml: 1 }} />
                        )}
                    </Typography>

                    {question.course_answers && (
                        <Typography
                            sx={{
                                textAlign: "left",
                                fontSize: {
                                    xs: '8vw',
                                    sm: '4vw',
                                    md: '3vw',
                                    lg: '2vw',
                                    xl: '.75vw',
                                },
                                fontFamily: 'Poppins',
                                fontWeight: 300,
                                color: "black",
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "center",
                                cursor: 'pointer',
                            }}
                            onClick={() => setSelectedQuestion(question)}
                        >
                            {question.course_answers.length} <Chat sx={{ ml: 1 }} />
                        </Typography>
                    )}
                </Box>
            </Grid>

            {/*<Grid
                size={12}
                sx={{ mb: 1 }}
            >
                <Divider sx={{ my: 1, borderColor: "gray" }} />
            </Grid>*/}

        </Grid>



    )
}