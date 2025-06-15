"use client";
import React, { useState } from 'react';
import {
    Box,
    Typography,
    Grid,
    Button,
    Tooltip,
    Divider,
    TextField,
    FormControl,
    InputLabel,
    OutlinedInput,
    InputAdornment,
    IconButton,
    Checkbox,
    FormGroup,
    FormControlLabel,
    Snackbar,
    Alert,
    FormHelperText,
} from "@mui/material";
import Link from "next/link";
import Image from "next/image";

import {
    Google,
    Visibility,
    VisibilityOff,
    ArrowBack,
} from "@mui/icons-material";

// Custom Components
/*import {
    handleSendResetPasswordEmail,
} from "@/app/Header/Signin/actions";*/
import AnimatedButton from "@/app/Buttons/AnimatedButton";

export default function ForgotPasswordForm() {
    const [formValues, setFormValue] = useState({
        email: "",
    });
    const [errors, setErrors] = useState({
        email: false,
    });

    const [errorMessage, setErrorMessage] = useState('');
    const [openError, setOpenError] = useState(false);
    const [openSuccess, setOpenSuccess] = useState(false);

    const iconSize = {
        xs: '6vw',
        sm: '4vw',
        md: '1vw',
        lg: '1vw',
        xl: '1vw',
    }

    const handleResetPasswordForm = async () => {
        const { email } = formValues;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        const newErrors = {
            email: !email || !emailRegex.test(email),
        };

        setErrors(newErrors);

        if (!email) {
            setErrorMessage("Email is required.");
        } else if (!emailRegex.test(email)) {
            setErrorMessage("Please enter a valid email address.");
        }

        const hasError = Object.values(newErrors).some(Boolean);
        setOpenError(hasError); // Show Snackbar if there's an error
        if (hasError) return;

        // Call Supabase
        //const resp = await handleSendResetPasswordEmail(email);

        if (!resp) {
            let errorMessage = "Sign In Error. Revalidate Credentials.";
            if (supabaseError.includes("Email address") && supabaseError.includes("invalid")) {
                errorMessage = "Invalid email address.";
            }

            setErrors((prev) => ({
                ...prev,
                email: true,
            })); // Set email error to true if the error is related to email
            setErrorMessage(errorMessage);
            setOpenError(true);
            return;
        } else {
            setErrorMessage("Password reset email sent successfully. Please check your inbox.");
            setOpenSuccess(true);
        }
    }

    const handleCloseError = () => {
        setOpenError(false);
    }

    return (
        <Box
            sx={{
                height: "93%",
                width: "100%",
                backgroundColor: "#F0F0F0",
                px: "3vw",
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
            }}
        >
            <Grid
                container
                rowSpacing={3}
                columnSpacing={3}
                sx={{
                    width: '100%',
                }}
            >

                <Grid size={12}>
                    <Typography
                        sx={{
                            textAlign: 'center',
                            fontFamily: 'Poppins',
                            fontWeight: 700,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '2vw',
                            },
                            color: "black",
                        }}
                    >
                        Forgot Your Password?
                    </Typography>
                    <Typography
                        sx={{
                            textAlign: 'center',
                            fontFamily: 'Poppins',
                            fontWeight: 500,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '1vw',
                            },
                            color: "black",
                        }}
                    >
                        No worries, we'll send you password reset instructions.
                    </Typography>
                </Grid>

                <Grid size={12}>
                    <TextField
                        fullWidth
                        label="Email Address"
                        variant="outlined"
                        size="normal"
                        sx={{
                            fontFamily: 'Poppins',
                            fontWeight: 400,
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '1vw',
                            },
                            color: "black",
                            borderRadius: '999px',
                        }}
                        required
                        onChange={(e) => setFormValue({ ...formValues, email: e.target.value })}
                        error={errors.email}
                        helperText={errors.email ? "Valid email is required" : ""}
                    />
                </Grid>

                <Grid size={12}>
                    <AnimatedButton
                        color="#87CEEB"
                        reverse={true}
                        borderRadius="50px"
                        hoverTextColor="black"
                        reverseHoverColor="black"
                        size="large"
                        text="Reset Password"
                        border="3px solid #87CEEB"
                        fullWidth={true}
                        onclick={handleResetPasswordForm}
                    />
                </Grid>

                <Grid
                    size={12}
                    sx={{
                        display: 'flex',
                        justifyContent: 'center',
                        alignItems: 'center',
                        '& :hover': {
                            transform: 'scale(1.05)',
                            transition: 'transform 0.3s ease',
                        },
                    }}
                >
                    <Link href="/signin" passHref>
                        <Box
                            sx={{
                                display: 'flex',
                                flexDirection: 'row',
                                alignItems: 'center',
                                justifyContent: 'center',
                                gap: 1,

                            }}
                        >
                            <ArrowBack
                                sx={{
                                    fontSize: iconSize,
                                    color: "black",
                                    cursor: 'pointer',
                                }}
                            />
                            <Typography
                                sx={{
                                    fontSize: {
                                        xs: '4vw',
                                        sm: '2.5vw',
                                        md: '1.8vw',
                                        lg: '1.25vw',
                                        xl: '.75vw',
                                    },
                                    fontFamily: 'Poppins',
                                    fontWeight: 400,
                                    color: "black",
                                    textAlign: 'center',
                                }}
                            >
                                Return to Signin
                            </Typography>
                        </Box>
                    </Link>

                </Grid>

            </Grid>

            <Snackbar
                open={openError}
                autoHideDuration={6000}
                onClose={handleCloseError}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
            >
                <Alert
                    onClose={handleCloseError}
                    severity="error"
                    sx={{ width: '100%' }}
                >
                    {errorMessage}
                </Alert>
            </Snackbar>
             <Snackbar
                open={openSuccess}
                autoHideDuration={6000}
                onClose={handleCloseError}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
            >
                <Alert
                    onClose={handleCloseError}
                    severity="success"
                    sx={{ width: '100%' }}
                >
                    {errorMessage}
                </Alert>
            </Snackbar>
        </Box >
    );
}
