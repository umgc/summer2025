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
import { useRouter } from "next/navigation";

import {
    ArrowBack,
    ArrowForward,
    Google,
    Visibility,
    VisibilityOff,
} from "@mui/icons-material";

// Custom Components
import {
    handleSignup,
    loginWithGoogle,
} from "@/utils/supabase/client";
import AnimatedButton from "@/app/Buttons/AnimatedButton";

export default function SignupForm() {
    const router = useRouter();
    const [showPassword, setShowPassword] = React.useState(false);
    const [formValues, setFormValue] = useState({
        firstName: "",
        lastName: "",
        email: "",
        password: "",
        terms: false,
    });
    const [errors, setErrors] = useState({
        firstName: false,
        lastName: false,
        email: false,
        password: false,
        terms: false,
    });

    const [errorMessage, setErrorMessage] = useState('');
    const [openError, setOpenError] = useState(false);
    const [successMessage, setSuccessMessage] = useState('');
    const [openSuccess, setOpenSuccess] = useState(false);
    const [successSwitch, setSuccessSwitch] = useState(false);

    const iconSize = {
        xs: '6vw',
        sm: '4vw',
        md: '1vw',
        lg: '1vw',
        xl: '1vw',
    }

    const handleClickShowPassword = () => setShowPassword((show) => !show);
    const handleMouseDownPassword = (event) => {
        event.preventDefault();
    };
    const handleMouseUpPassword = (event) => {
        event.preventDefault();
    };

    const handleSignUpDefault = async () => {
        const { firstName, lastName, email, password, terms } = formValues;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        const newErrors = {
            firstName: !firstName,
            lastName: !lastName,
            email: !email || !emailRegex.test(email),
            password: !password || password.length < 8,
            terms: !terms,
        };

        setErrors(newErrors);

        if (newErrors.firstName) {
            setErrorMessage("First name is required.");
        } else if (newErrors.lastName) {
            setErrorMessage("Last name is required.");
        } else if (!email) {
            setErrorMessage("Email is required.");
        } else if (!emailRegex.test(email)) {
            setErrorMessage("Please enter a valid email address.");
        } else if (!password) {
            setErrorMessage("Password is required.");
        } else if (password.length < 8) {
            setErrorMessage("Password must be at least 8 characters.");
        } else if (!terms) {
            setErrorMessage("You must agree to the Terms & Conditions.");
        }

        const hasError = Object.values(newErrors).some(Boolean);
        setOpenError(hasError); // Show Snackbar if there's an error
        if (hasError) return;

        // Call Supabase
        const supabaseError = await handleSignup(formValues);
        console.log("Supabase Error:", supabaseError);

        if (supabaseError) {
            let errorMessage = "Sign Up Error. Revalidate Credentials.";
            if (supabaseError.includes("Email already registered")) {
                errorMessage = "Email already registered.";
            } else if (supabaseError.includes("Email address") && supabaseError.includes("invalid")) {
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
            setSuccessMessage("Sign Up Successful! Please check your email for verification.");
            setOpenSuccess(true);
            setSuccessSwitch(true);
            // Optionally redirect to dashboard or home page
            // router.push("/dashboard");
        }
    };

    const handleCloseError = () => {
        setOpenError(false);
    }

    const handleClose = () => {
        setOpenSuccess(false);
    }

    const handleRetrySignUp = () => {
        setSuccessSwitch(false);
        setFormValue({
            firstName: "",
            lastName: "",
            email: "",
            password: "",
            terms: false,
        });
        setErrors({
            firstName: false,
            lastName: false,
            email: false,
            password: false,
            terms: false,
        });
        setErrorMessage('');
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

                {successSwitch ? (
                    <>
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
                                Welcome to DeepTrain
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
                                Check your email for verification and get started with your training journey!
                            </Typography>
                        </Grid>

                        <Grid size={12}>
                            <Box
                                sx={{
                                    display: 'flex',
                                    flexDirection: 'row',
                                    justifyContent: 'center',
                                    alignItems: 'center',
                                    //width: '100%',
                                    gap: 2,
                                }}
                            >
                            <AnimatedButton
                                color="#DC143C"
                                reverse={true}
                                borderRadius="50px"
                                hoverTextColor="white"
                                reverseHoverColor="black"
                                size="large"
                                text="Retry Sign Up"
                                border="3px solid #DC143C"
                                fullWidth={true}
                                icon="true"
                                startIcon={<ArrowBack />}
                                onclick={handleRetrySignUp}
                            />
                            <AnimatedButton
                                color="#87CEEB"
                                reverse={true}
                                borderRadius="50px"
                                hoverTextColor="black"
                                reverseHoverColor="black"
                                size="large"
                                text="Proceed to Sign In"
                                border="3px solid #87CEEB"
                                fullWidth={true}
                                icon="true"
                                endIcon={<ArrowForward />}
                                onclick={() =>  router.push("/signin")}
                            />
                            </Box>
                        </Grid>
                    </>
                ) : (
                    <>
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
                                Get Started with DeepTrain
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
                                Enter your credentials to create an account
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
                                Sign Up with Google
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

                        <Grid size={6}>
                            <TextField
                                fullWidth
                                label="First Name"
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
                                }}
                                required
                                onChange={(e) => setFormValue({ ...formValues, firstName: e.target.value })}
                                error={errors.firstName}
                                helperText={errors.firstName ? "First name is required" : ""}
                            />
                        </Grid>
                        <Grid size={6}>
                            <TextField
                                fullWidth
                                label="Last Name"
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
                                }}
                                required
                                onChange={(e) => setFormValue({ ...formValues, lastName: e.target.value })}
                                error={errors.lastName}
                                helperText={errors.lastName ? "Last name is required" : ""}
                            />
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
                                //error={errors.password}
                                //helperText={errors.password ? "Password must be at least 8 characters" : ""}
                                />
                                {errors.password && (
                                    <FormHelperText>
                                        Password must be at least 8 characters
                                    </FormHelperText>
                                )}
                            </FormControl>
                        </Grid>

                        <Grid size={12}>
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
                                            checked={formValues.terms}
                                            onChange={(e) => setFormValue({ ...formValues, terms: e.target.checked })}
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
                                            I agree to the{" "}
                                            <Link
                                                href="/"
                                                passHref
                                                style={{
                                                    textDecoration: 'underline',
                                                    fontWeight: 500,
                                                }}
                                            >
                                                Terms & Conditions
                                            </Link>
                                        </Typography>
                                    }
                                />
                            </FormGroup>
                        </Grid>

                        <Grid size={12}>
                            <AnimatedButton
                                color="#87CEEB"
                                reverse={true}
                                borderRadius="50px"
                                hoverTextColor="black"
                                reverseHoverColor="black"
                                size="large"
                                text="Sign Up"
                                border="3px solid #87CEEB"
                                fullWidth={true}
                                onclick={handleSignUpDefault}
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
                                Already have an account?{" "}
                                <a href="/signin" style={{ color: 'black', textDecoration: 'underline' }}>
                                    Sign In
                                </a>
                            </Typography>
                        </Grid>
                    </>
                )}

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
                onClose={handleClose}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
            >
                <Alert
                    onClose={handleClose}
                    severity="success"
                    sx={{ width: '100%' }}
                >
                    {successMessage}
                </Alert>
            </Snackbar>
        </Box >
    );
}
