'use client';
import React, { useState, useEffect } from 'react';
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
import { useSearchParams } from 'next/navigation';

import {
    Google,
    Visibility,
    VisibilityOff,
    ArrowBack,
} from "@mui/icons-material";

// Supabase
import { createClient } from "@/utils/supabase/client";

// Custom Components
import AnimatedButton from "@/app/Buttons/AnimatedButton";

export default function ResetPasswordForm() {
    const searchParams = useSearchParams();
    const [showPassword, setShowPassword] = React.useState(false);
    const [formValues, setFormValue] = useState({
        password: "",
        confirmPassword: "",
    });
    const [errors, setErrors] = useState({
        password: false,
        confirmPassword: false,
    });
    const [linkExpired, setLinkExpired] = useState(false);
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

    /*useEffect(() => {
        const checkSession = async () => {
            const supabase = createClient();
            const { data: { session }, error } = await supabase.auth.getSession()

            if (error) {
                console.error('Error checking session:', error.message)
                setErrorMessage('There was an error verifying the session.')
                //setLoading(false)
                return
            }

            if (!session) {
                setErrorMessage('This password reset link has expired or is invalid.')
                //setLoading(false)
                return
            }

            //setSessionValid(true)
            //setLoading(false)
        }

        checkSession()
    }, [])*/

    useEffect(() => {
        const code = searchParams.get('code');
        const error = searchParams.get('error');
        const errorDescription = searchParams.get('error_description');

        // Case 1: No code at all
        if (!code) {
            setLinkExpired(true);
            console.warn("⚠️ No `code` found in URL. Link might be invalid.");
            return;
        }

        // Case 2: Explicit error from Supabase in URL
        if (error || errorDescription) {
            setLinkExpired(true);
            console.warn("⚠️ Supabase returned error:", errorDescription);
            return;
        }

        // If code exists and no error, assume it's valid until proven otherwise
        setLinkExpired(false);
    }, [searchParams]);


    const handleClickShowPassword = () => setShowPassword((show) => !show);
    const handleMouseDownPassword = (event) => {
        event.preventDefault();
    };
    const handleMouseUpPassword = (event) => {
        event.preventDefault();
    };

    const handleResetPasswordForm = async () => {
        const { password, confirmPassword } = formValues;

        const newErrors = {
            password: !password || password.length < 8 || password !== confirmPassword,
            confirmPassword: !confirmPassword || confirmPassword.length < 8 || password !== confirmPassword,
        };
        setErrors(newErrors);

        if (!password || !confirmPassword) {
            setErrorMessage("Password is required.");
        } else if (password.length < 8 || confirmPassword.length < 8) {
            setErrorMessage("Password must be at least 8 characters.");
        } else if (password !== confirmPassword) {
            setErrorMessage("Passwords do not match.");
        }

        const hasError = Object.values(newErrors).some(Boolean);
        setOpenError(hasError); // Show Snackbar if there's an error
        if (hasError) return;

        // Call Supabase
        //const resp = await handleResetPassword(password);
        console.log("Resetting Password:", password);
        const supabase = createClient();
        const { data, error } = await supabase.auth.updateUser({
            password,
        });
        console.log("Supabase Error:", data, error);

        if (error) {
            console.error("Supabase Error:", error);
            let errorMessage = "Password Reset Error";

            setErrors((prev) => ({
                ...prev,
                password: true,
            }));
            setErrorMessage(errorMessage);
            setOpenError(true);
            return;
        } else {
            setErrorMessage("Password Reset");
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
            {linkExpired ? (
                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',                       
                    }}
                >
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
                            color: "red",
                        }}
                    >
                        Link Expired or Invalid
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
                        The password reset link you used is either
                        expired, invalid, or already used.
                        Please try again.
                    </Typography>
                    
                    <Link href="/signin" passHref>
                        <Box
                            sx={{
                                display: 'flex',
                                flexDirection: 'row',
                                alignItems: 'center',
                                justifyContent: 'center',
                                gap: 1,
                                mt: 1,
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
                </Box>
            ) : (
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
                            Set New Password
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
                            New password must be at least 8 characters long.
                        </Typography>
                    </Grid>


                    <Grid size={12}>
                        <FormControl sx={{ width: '100%' }} variant="outlined">
                            <InputLabel htmlFor="outlined-adornment-password">
                                Password
                            </InputLabel>
                            <OutlinedInput
                                id="outlined-adornment-password"
                                type={showPassword ? 'text' : 'password'}
                                endAdornment={
                                    <InputAdornment position="end">
                                        <IconButton
                                            aria-label={
                                                showPassword ? 'hide the password' : 'display the password'
                                            }
                                            onClick={handleClickShowPassword}
                                            onMouseDown={handleMouseDownPassword}
                                            onMouseUp={handleMouseUpPassword}
                                            edge="end"
                                        >
                                            {showPassword ? <VisibilityOff /> : <Visibility />}
                                        </IconButton>
                                    </InputAdornment>
                                }
                                label="Password"
                                required
                                onChange={(e) => setFormValue({ ...formValues, password: e.target.value })}
                            />
                            {errors.password && (
                                <FormHelperText>
                                    Password must be at least 8 characters
                                </FormHelperText>
                            )}
                        </FormControl>
                    </Grid>

                    <Grid size={12}>
                        <FormControl sx={{ width: '100%' }} variant="outlined">
                            <InputLabel htmlFor="outlined-adornment-password-confirm">
                                Confirm Password
                            </InputLabel>
                            <OutlinedInput
                                id="outlined-adornment-password-confirm"
                                type='password'
                                label="Confirm Password"
                                required
                                onChange={(e) => setFormValue({ ...formValues, confirmPassword: e.target.value })}
                            />
                        </FormControl>
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

            )}
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
