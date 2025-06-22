"use client"
import { Card, CardContent, Typography, Button, Box, Avatar, Chip, Stack } from "@mui/material"
import { EmojiEvents, Star, Celebration, ArrowForward, Refresh } from "@mui/icons-material"
import { useState, useEffect } from "react"
import { setUser } from "@sentry/nextjs"

const CongratulationsScreen = ({
    score = null,
    onContinue = () => { },
    onRetry = () => { },
    showRetryOption = true,
    subHeight,
    user,
    currentProject = null,
}) => {
    const [isVisible, setIsVisible] = useState(false)
    const [userInfo, setUserInfo] = useState(null)

    useEffect(() => {
        // Trigger animation after component mounts
        const timer = setTimeout(() => setIsVisible(true), 100)
        return () => clearTimeout(timer)
    }, [])

    useEffect(() => {
        if (user && user.id) {
            // Fetch user info if available
            setUserInfo(
                user.identities
                    ? user.identities[0].identity_data
                    : { name: user.name || "User", email: user.email || "user@example.com" }
            )
            //console.log("User Info:", userInfo);
        }
    }, [user])

    return (
        <Box
            sx={{
                display: "flex",
                justifyContent: "center",
                alignItems: "center",
                height: subHeight,
                background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
                padding: 2,
                opacity: isVisible ? 1 : 0,
                transform: isVisible ? "translateY(0)" : "translateY(20px)",
                transition: "all 0.8s ease-out",
            }}
        >
            <Card
                sx={{
                    maxWidth: 500,
                    width: "100%",
                    textAlign: "center",
                    borderRadius: 4,
                    boxShadow: "0 20px 40px rgba(0,0,0,0.1)",
                    overflow: "visible",
                    position: "relative",
                    opacity: isVisible ? 1 : 0,
                    transform: isVisible ? "scale(1) translateY(0)" : "scale(0.9) translateY(20px)",
                    transition: "all 0.6s cubic-bezier(0.34, 1.56, 0.64, 1)",
                    transitionDelay: "0.2s",
                }}
            >
                {/* Floating celebration icon */}
                <Box
                    sx={{
                        position: "absolute",
                        top: -30,
                        left: "50%",
                        transform: "translateX(-50%)",
                        zIndex: 1,
                        opacity: isVisible ? 1 : 0,
                        animation: isVisible ? "bounce 2s infinite" : "none",
                        "@keyframes bounce": {
                            "0%, 20%, 50%, 80%, 100%": {
                                transform: "translateX(-50%) translateY(0)",
                            },
                            "40%": {
                                transform: "translateX(-50%) translateY(-10px)",
                            },
                            "60%": {
                                transform: "translateX(-50%) translateY(-5px)",
                            },
                        },
                    }}
                >
                    <Avatar
                        sx={{
                            width: 60,
                            height: 60,
                            bgcolor: "#ffd700",
                            boxShadow: "0 8px 16px rgba(255,215,0,0.3)",
                        }}
                    >
                        <EmojiEvents sx={{ fontSize: 32, color: "#fff" }} />
                    </Avatar>
                </Box>

                <CardContent sx={{ pt: 6, pb: 4, px: 4 }}>
                    {/* Congratulations Header */}
                    <Typography
                        variant="h3"
                        component="h1"
                        sx={{
                            fontWeight: "bold",
                            background: "linear-gradient(45deg, #667eea, #764ba2)",
                            backgroundClip: "text",
                            WebkitBackgroundClip: "text",
                            WebkitTextFillColor: "transparent",
                            mb: 2,
                            opacity: isVisible ? 1 : 0,
                            transform: isVisible ? "translateY(0)" : "translateY(30px)",
                            transition: "all 0.8s ease-out",
                            transitionDelay: "0.4s",
                        }}
                    >
                        Congratulations!
                    </Typography>

                    {/* Celebration Icons */}
                    <Stack
                        direction="row"
                        justifyContent="center"
                        spacing={1}
                        sx={{
                            mb: 3,
                            opacity: isVisible ? 1 : 0,
                            transform: isVisible ? "translateY(0)" : "translateY(20px)",
                            transition: "all 0.6s ease-out",
                            transitionDelay: "0.6s",
                        }}
                    >
                        <Star sx={{ color: "#ffd700", fontSize: 24 }} />
                        <Celebration sx={{ color: "#ff6b6b", fontSize: 24 }} />
                        <Star sx={{ color: "#ffd700", fontSize: 24 }} />
                    </Stack>

                    {/* Success Message */}
                    <Typography
                        variant="h6"
                        color="text.secondary"
                        sx={{
                            mb: 2,
                            opacity: isVisible ? 1 : 0,
                            transform: isVisible ? "translateY(0)" : "translateY(20px)",
                            transition: "all 0.6s ease-out",
                            transitionDelay: "0.8s",
                        }}
                    >
                        Well done, {userInfo?.name || "Student"}!
                    </Typography>

                    <Typography
                        variant="body1"
                        color="text.secondary"
                        sx={{
                            mb: 3,
                            opacity: isVisible ? 1 : 0,
                            transform: isVisible ? "translateY(0)" : "translateY(20px)",
                            transition: "all 0.6s ease-out",
                            transitionDelay: "1s",
                        }}
                    >
                        You have successfully completed <strong>"{currentProject.name}"</strong>
                    </Typography>

                    {/* Score Display (if provided) */}
                    {score !== null && (
                        <Box
                            sx={{
                                mb: 3,
                                opacity: isVisible ? 1 : 0,
                                transform: isVisible ? "scale(1)" : "scale(0.8)",
                                transition: "all 0.6s ease-out",
                                transitionDelay: "1.2s",
                            }}
                        >
                            <Chip
                                label={`Score: ${score}%`}
                                color={score >= 80 ? "success" : score >= 60 ? "warning" : "error"}
                                variant="outlined"
                                sx={{
                                    fontSize: "1.1rem",
                                    height: 40,
                                    fontWeight: "bold",
                                }}
                            />
                        </Box>
                    )}

                    {/* Motivational Message */}
                    <Typography
                        variant="body2"
                        sx={{
                            fontStyle: "italic",
                            color: "text.secondary",
                            mb: 4,
                            px: 2,
                            opacity: isVisible ? 1 : 0,
                            transform: isVisible ? "translateY(0)" : "translateY(20px)",
                            transition: "all 0.6s ease-out",
                            transitionDelay: "1.4s",
                        }}
                    >
                        "Learning is a treasure that will follow its owner everywhere."
                    </Typography>

                    {/* Action Buttons */}
                    <Stack
                        spacing={2}
                        direction={{ xs: "column", sm: "row" }}
                        justifyContent="center"
                        sx={{
                            opacity: isVisible ? 1 : 0,
                            transform: isVisible ? "translateY(0)" : "translateY(30px)",
                            transition: "all 0.6s ease-out",
                            transitionDelay: "1.6s",
                        }}
                    >
                        <Button
                            variant="contained"
                            size="large"
                            endIcon={<ArrowForward />}
                            onClick={onContinue}
                            sx={{
                                background: "linear-gradient(45deg, #667eea, #764ba2)",
                                borderRadius: 3,
                                textTransform: "none",
                                fontSize: "1.1rem",
                                py: 1.5,
                                px: 3,
                                "&:hover": {
                                    background: "linear-gradient(45deg, #5a6fd8, #6a42a0)",
                                    transform: "translateY(-2px)",
                                    boxShadow: "0 8px 16px rgba(102,126,234,0.3)",
                                },
                                transition: "all 0.3s ease",
                            }}
                        >
                            Continue Learning
                        </Button>

                        {showRetryOption && (
                            <Button
                                variant="outlined"
                                size="large"
                                startIcon={<Refresh />}
                                onClick={onRetry}
                                sx={{
                                    borderRadius: 3,
                                    textTransform: "none",
                                    fontSize: "1.1rem",
                                    py: 1.5,
                                    px: 3,
                                    borderColor: "#667eea",
                                    color: "#667eea",
                                    "&:hover": {
                                        borderColor: "#5a6fd8",
                                        backgroundColor: "rgba(102,126,234,0.04)",
                                        transform: "translateY(-2px)",
                                    },
                                    transition: "all 0.3s ease",
                                }}
                            >
                                Retry Lesson
                            </Button>
                        )}
                    </Stack>
                </CardContent>
            </Card>
        </Box>
    )
}

export default CongratulationsScreen
