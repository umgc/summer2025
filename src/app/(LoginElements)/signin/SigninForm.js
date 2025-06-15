"use client";
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
import { useRouter } from 'next/navigation';

import {
    Google,
    Visibility,
    VisibilityOff,
} from "@mui/icons-material";

// Custom Components
import { 
    loginWithGoogle,
    loginClient
} from "@/utils/supabase/client";
import AnimatedButton from "@/app/Buttons/AnimatedButton";

export default function SigninForm() {
    const router = useRouter();
    const [showPassword, setShowPassword] = React.useState(false);
    const [formValues, setFormValue] = useState({
        email: "",
        password: "",
        rememberMe: false,
    });
    const [errors, setErrors] = useState({
        email: false,
        password: false,
    });
    const [errorMessage, setErrorMessage] = useState('');
    const [openError, setOpenError] = useState(false);

    const iconSize = {
        xs: '6vw',
        sm: '4vw',
        md: '1vw',
        lg: '1vw',
        xl: '1vw',
    }

    useEffect(() => {
        const savedEmail = localStorage.getItem('rememberedEmail');
        if (savedEmail) {
            setFormValue((prev) => ({ 
                ...prev, 
                email: savedEmail, 
                rememberMe: true 
            }));
        }
    }, []);

    const handleClickShowPassword = () => setShowPassword((show) => !show);
    const handleMouseDownPassword = (event) => {
        event.preventDefault();
    };
    const handleMouseUpPassword = (event) => {
        event.preventDefault();
    };

    const handleSignInDefault = async () => {
        const { email, password } = formValues;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        const newErrors = {
            email: !email || !emailRegex.test(email),
            password: !password || password.length < 8,
        };

        setErrors(newErrors);

        if (!email) {
            setErrorMessage("Email is required.");
        } else if (!emailRegex.test(email)) {
            setErrorMessage("Please enter a valid email address.");
        } else if (!password) {
            setErrorMessage("Password is required.");
        } else if (password.length < 8) {
            setErrorMessage("Password must be at least 8 characters.");
        }

        const hasError = Object.values(newErrors).some(Boolean);
        setOpenError(hasError); // Show Snackbar if there's an error
        if (hasError) return;

        // Call Supabase
        const resp = await loginClient(formValues);
        console.log("Supabase Response:", resp);

        if (resp !== true) {
            let errorMessage = "Sign In Error. Revalidate Credentials.";
            if (resp.includes("Email address") && resp.includes("invalid")) {
                errorMessage = "Invalid email address.";
            } else if (resp.includes("Invalid") && resp.includes("credentials")) {
                errorMessage = "Invalid credentials. Please check your email and password.";
            }

            setErrors((prev) => ({
                ...prev,
                email: true,
                password: true,
            }));
            setErrorMessage(errorMessage);
            setOpenError(true);
            return;
        }

        if (formValues.rememberMe) {
            localStorage.setItem('rememberedEmail', formValues.email);
        } else {
            localStorage.removeItem('rememberedEmail');
        }

        // If login is successful, redirect to the home page
        router.push('/'); // Redirect to the home page
    };

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
                        Login to DeepTrain
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
                        Enter your credentials to login into an account
                    </Typography>
                </Grid>

                <Grid size={12}>
                    <Button
                        variant="contained"
                        fullWidth
                        color="white"
                        disableElevation
                        sx={{
                            color: "black",
                            fontSize: {
                                xs: '4vw',
                                sm: '2.5vw',
                                md: '1.8vw',
                                lg: '1.25vw',
                                xl: '1vw',
                            },
                            fontFamily: 'Poppins',
                            fontWeight: 600,
                            textTransform: 'none',
                            borderRadius: '10px',
                            border: '2px solid black',
                            '&:hover': {
                                backgroundColor: 'black',
                                color: 'white',
                            },
                        }}
                        startIcon={
                            <Google
                                sx={{
                                    width: iconSize,
                                    height: iconSize,
                                    mr: .5,
                                }}
                            />
                        }
                        onClick={() => loginWithGoogle()}
                    >
                        Sign In with Google
                    </Button>
                </Grid>

                <Divider
                    sx={{
                        width: '100%',
                        color: "gray",
                        '&::before, &::after': {
                            borderTop: '2px solid gray',  // 4px thick line
                        },
                    }}
                >
                    <Typography
                        noWrap
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
                        }}
                    >
                        or
                    </Typography>
                </Divider>


                <Grid size={12}>
                    <TextField
                        fullWidth
                        label="Email Address"
                        variant="outlined"
                        size="normal"
                        value={formValues.email}
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
                    <FormControl
                        sx={{ width: '100%' }}
                        variant="outlined"
                        error={errors.password}
                        required
                    >
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
                            onChange={(e) => setFormValue({ ...formValues, password: e.target.value })}
                        />
                        {errors.password && (
                            <FormHelperText>
                                Password Invalid
                            </FormHelperText>
                        )}
                    </FormControl>
                </Grid>

                <Grid size={12}>
                    <Box
                        sx={{
                            display: 'flex',
                            flexDirection: 'row',
                            justifyContent: 'space-between',
                            width: '100%',
                        }}
                    >
                        <FormGroup
                            sx={{
                                display: 'flex',
                                justifyContent: 'center',
                                alignItems: 'flex-start',
                            }}
                        >
                            <FormControlLabel
                                control={
                                    <Checkbox
                                        checked={formValues.rememberMe}
                                        onChange={(e) => setFormValue({ ...formValues, rememberMe: e.target.checked })}
                                        sx={{
                                            color: 'black',
                                            '&.Mui-checked': {
                                                color: 'black',
                                            },
                                        }}

                                    />
                                }
                                label={
                                    <Typography
                                        sx={{
                                            fontFamily: 'Poppins',
                                            fontSize: {
                                                xs: '1.1vw',
                                                sm: '1.2vw',
                                                md: '1.3vw',
                                                lg: '1.4vw',
                                                xl: '.75vw',
                                            },
                                        }}
                                    >
                                        Remember Me
                                    </Typography>
                                }
                            />
                        </FormGroup>

                        <Button
                            variant='text'
                            disabled
                        >
                            <Link
                                href="/signin"
                                style={{
                                    textDecoration: 'none',
                                    color: 'inherit',
                                }}
                            >
                                <Typography
                                    sx={{
                                        fontFamily: 'Roboto',
                                        fontSize: {
                                            xs: '1.1vw',
                                            sm: '1.2vw',
                                            md: '1.3vw',
                                            lg: '1.4vw',
                                            xl: '.7vw',
                                        },
                                        fontWeight: 500,
                                        letterSpacing: '0px',
                                    }}
                                >
                                    Forgot Your Password?
                                </Typography>
                            </Link>
                        </Button>
                    </Box>
                </Grid>

                <Grid size={12}>
                    <AnimatedButton
                        color="#87CEEB"
                        reverse={true}
                        borderRadius="50px"
                        hoverTextColor="black"
                        reverseHoverColor="black"
                        size="large"
                        text="Sign In"
                        border="3px solid #87CEEB"
                        fullWidth={true}
                        onclick={handleSignInDefault}
                    />
                </Grid>

                <Grid size={12}>
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
                        Don't have an account?{" "}
                        <a href="/signup" style={{ color: 'black', textDecoration: 'underline' }}>
                            Sign Up
                        </a>
                    </Typography>

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
        </Box >
    );
}
