"use client"
import { useState, useEffect } from "react"
import {
  Box,
  Dialog,
  DialogTitle,
  DialogContent,
  Typography,
  Button,
  Divider,
  TextField,
  IconButton,
  InputAdornment,
  FormControl,
  OutlinedInput,
  Snackbar,
  Alert,
  FormGroup,
  FormControlLabel,
  Checkbox,
  CircularProgress,
} from "@mui/material"
import Link from "next/link"
import { useRouter } from "next/navigation"

//Icons
import { VisibilityOff, Visibility, Google } from "@mui/icons-material"

//Custom
import { loginClient, loginWithGoogle } from "../../../utils/supabase/client"

export default function SigninDialog({ signinOpen, handleClose }) {
  const router = useRouter()
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [googleLoading, setGoogleLoading] = useState(false)
  const [formValues, setFormValue] = useState({
    email: "",
    password: "",
    rememberMe: false,
  })
  const [errors, setErrors] = useState({
    email: false,
    password: false,
  })
  const [errorMessage, setErrorMessage] = useState("")
  const [openError, setOpenError] = useState(false)
  const [successMessage, setSuccessMessage] = useState("")
  const [openSuccess, setOpenSuccess] = useState(false)

  const iconSize = {
    xs: "6vw",
    sm: "4vw",
    md: "1vw",
    lg: "1vw",
    xl: "1vw",
  }

  useEffect(() => {
    if (typeof window !== "undefined") {
      const savedEmail = localStorage.getItem("rememberedEmail")
      if (savedEmail) {
        setFormValue((prev) => ({
          ...prev,
          email: savedEmail,
          rememberMe: true,
        }))
      }
    }
  }, [])

  const handleClickShowPassword = () => setShowPassword((show) => !show)

  const handleMouseDownPassword = (event) => {
    event.preventDefault()
  }

  const handleMouseUpPassword = (event) => {
    event.preventDefault()
  }

  const handleSignInDefault = async () => {
    const { email, password } = formValues
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

    const newErrors = {
      email: !email || !emailRegex.test(email),
      password: !password || password.length < 6, // Changed from 8 to 6 for more flexibility
    }

    setErrors(newErrors)

    if (!email) {
      setErrorMessage("Email is required.")
    } else if (!emailRegex.test(email)) {
      setErrorMessage("Please enter a valid email address.")
    } else if (!password) {
      setErrorMessage("Password is required.")
    } else if (password.length < 6) {
      setErrorMessage("Password must be at least 6 characters.")
    }

    const hasError = Object.values(newErrors).some(Boolean)
    setOpenError(hasError)
    if (hasError) return

    setLoading(true)

    try {
      // Call Supabase
      const resp = await loginClient(formValues)
      console.log("Supabase Response:", resp)

      if (resp !== true) {
        let errorMessage = "Sign In Error. Please check your credentials."

        if (typeof resp === "string") {
          if (resp.includes("Email not confirmed")) {
            errorMessage = "Please check your email and confirm your account before signing in."
          } else if (resp.includes("Invalid login credentials")) {
            errorMessage = "Invalid email or password. Please try again."
          } else if (resp.includes("Email address") && resp.includes("invalid")) {
            errorMessage = "Invalid email address."
          } else if (resp.includes("Invalid") && resp.includes("credentials")) {
            errorMessage = "Invalid credentials. Please check your email and password."
          } else if (resp.includes("Too many requests")) {
            errorMessage = "Too many login attempts. Please wait a moment and try again."
          }
        }

        setErrors((prev) => ({
          ...prev,
          email: true,
          password: true,
        }))
        setErrorMessage(errorMessage)
        setOpenError(true)
        return
      }

      // Handle remember me
      if (typeof window !== "undefined") {
        if (formValues.rememberMe) {
          localStorage.setItem("rememberedEmail", formValues.email)
        } else {
          localStorage.removeItem("rememberedEmail")
        }
      }

      // Success
      setSuccessMessage("Successfully signed in! Redirecting...")
      setOpenSuccess(true)

      // Close dialog and redirect after a short delay
      setTimeout(() => {
        handleClose()
        router.push("/") // Redirect to home page for now
        router.refresh() // Refresh to update auth state
      }, 1500)
    } catch (error) {
      console.error("Unexpected error:", error)
      setErrorMessage("An unexpected error occurred. Please try again.")
      setOpenError(true)
    } finally {
      setLoading(false)
    }
  }

  const handleGoogleSignIn = async () => {
    setGoogleLoading(true)

    try {
      const resp = await loginWithGoogle()

      if (resp !== true) {
        setErrorMessage("Google sign-in failed. Please try again.")
        setOpenError(true)
        setGoogleLoading(false)
      }
      // Note: For OAuth, the redirect happens automatically
      // so we don't need to handle success here
    } catch (error) {
      console.error("Google sign-in error:", error)
      setErrorMessage("Google sign-in failed. Please try again.")
      setOpenError(true)
      setGoogleLoading(false)
    }
  }

  const handleCloseError = () => {
    setOpenError(false)
  }

  const handleCloseSuccess = () => {
    setOpenSuccess(false)
  }

  return (
    <>
      <Dialog
        open={signinOpen}
        onClose={handleClose}
        maxWidth="sm"
        fullWidth
        sx={{
          "& .MuiDialog-paper": {
            borderRadius: "20px",
            p: 2,
          },
        }}
      >
        <DialogTitle
          sx={{
            fontSize: {
              xs: "4vw",
              sm: "2.5vw",
              md: "1.8vw",
              lg: "1.25vw",
              xl: "1.25vw",
            },
            fontFamily: "Montserrat",
            fontWeight: 700,
            color: "black",
            lineHeight: 1.1,
          }}
        >
          Sign In to DeepTrain
        </DialogTitle>
        <DialogContent
          sx={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            p: 2,
            gap: 2,
          }}
        >
          <TextField
            placeholder="Email"
            variant="outlined"
            fullWidth
            value={formValues.email}
            sx={{
              border: errors.email ? "2px solid red" : "2px solid black",
              borderRadius: "10px",
            }}
            slotProps={{
              input: {
                sx: {
                  fontSize: {
                    xs: "4vw",
                    sm: "2.5vw",
                    md: "1.8vw",
                    lg: "1.25vw",
                    xl: "1vw",
                  },
                  fontFamily: "Roboto",
                  fontWeight: 400,
                  color: "black",
                  px: 1,
                },
              },
            }}
            onChange={(e) => setFormValue({ ...formValues, email: e.target.value })}
            error={errors.email}
            disabled={loading || googleLoading}
          />

          <FormControl
            fullWidth
            sx={{
              border: errors.password ? "2px solid red" : "2px solid black",
              borderRadius: "10px",
            }}
            variant="outlined"
            required
            error={errors.password}
          >
            <OutlinedInput
              id="outlined-adornment-password"
              type={showPassword ? "text" : "password"}
              placeholder="Password"
              value={formValues.password}
              endAdornment={
                <InputAdornment position="end">
                  <IconButton
                    aria-label={showPassword ? "hide the password" : "display the password"}
                    onClick={handleClickShowPassword}
                    onMouseDown={handleMouseDownPassword}
                    onMouseUp={handleMouseUpPassword}
                    edge="end"
                    sx={{
                      pr: 3,
                      "& svg": {
                        fontSize: {
                          xs: "4vw",
                          sm: "2.5vw",
                          md: "1.8vw",
                          lg: "1.25vw",
                          xl: "1.1vw",
                        },
                      },
                    }}
                    disabled={loading || googleLoading}
                  >
                    {showPassword ? <VisibilityOff /> : <Visibility />}
                  </IconButton>
                </InputAdornment>
              }
              slotProps={{
                input: {
                  sx: {
                    fontSize: {
                      xs: "4vw",
                      sm: "2.5vw",
                      md: "1.8vw",
                      lg: "1.25vw",
                      xl: "1vw",
                    },
                    fontFamily: "Roboto",
                    fontWeight: 400,
                    color: "black",
                    px: 3,
                  },
                },
              }}
              onChange={(e) => setFormValue({ ...formValues, password: e.target.value })}
              disabled={loading || googleLoading}
            />
          </FormControl>

          <Box
            sx={{
              display: "flex",
              flexDirection: "row",
              justifyContent: "space-between",
              width: "100%",
            }}
          >
            <FormGroup
              sx={{
                display: "flex",
                justifyContent: "center",
                alignItems: "flex-start",
              }}
            >
              <FormControlLabel
                control={
                  <Checkbox
                    checked={formValues.rememberMe}
                    onChange={(e) => setFormValue({ ...formValues, rememberMe: e.target.checked })}
                    sx={{
                      color: "black",
                      "&.Mui-checked": {
                        color: "black",
                      },
                    }}
                    disabled={loading || googleLoading}
                  />
                }
                label={
                  <Typography
                    sx={{
                      fontFamily: "Poppins",
                      fontSize: {
                        xs: "1.1vw",
                        sm: "1.2vw",
                        md: "1.3vw",
                        lg: "1.4vw",
                        xl: ".75vw",
                      },
                    }}
                  >
                    Remember Me
                  </Typography>
                }
              />
            </FormGroup>

            <Button variant="text" disabled={loading || googleLoading}>
              <Link
                href="/forgot-password"
                style={{
                  textDecoration: "none",
                  color: "inherit",
                }}
              >
                <Typography
                  sx={{
                    fontFamily: "Roboto",
                    fontSize: {
                      xs: "1.1vw",
                      sm: "1.2vw",
                      md: "1.3vw",
                      lg: "1.4vw",
                      xl: ".7vw",
                    },
                    fontWeight: 500,
                    letterSpacing: "0px",
                  }}
                >
                  Forgot Your Password?
                </Typography>
              </Link>
            </Button>
          </Box>

          <Button
            variant="contained"
            fullWidth
            sx={{
              background: "linear-gradient(45deg, #2563eb, #1d4ed8)",
              color: "white",
              fontSize: {
                xs: "4vw",
                sm: "2.5vw",
                md: "1.8vw",
                lg: "1.25vw",
                xl: "1vw",
              },
              fontFamily: "Poppins",
              fontWeight: 600,
              textTransform: "none",
              borderRadius: "10px",
              "&:hover": {
                background: "linear-gradient(45deg, #1d4ed8, #1e40af)",
              },
              "&:disabled": {
                background: "rgba(0, 0, 0, 0.12)",
              },
            }}
            onClick={handleSignInDefault}
            disabled={loading || googleLoading}
          >
            {loading ? <CircularProgress size={24} color="inherit" /> : "Continue with email"}
          </Button>

          <Divider
            sx={{
              width: "100%",
              color: "gray",
              "&::before, &::after": {
                borderTop: "2px solid gray",
              },
            }}
          >
            or
          </Divider>

          <Button
            variant="contained"
            fullWidth
            color="white"
            disableElevation
            sx={{
              color: "black",
              fontSize: {
                xs: "4vw",
                sm: "2.5vw",
                md: "1.8vw",
                lg: "1.25vw",
                xl: "1vw",
              },
              fontFamily: "Poppins",
              fontWeight: 600,
              textTransform: "none",
              borderRadius: "10px",
              border: "2px solid black",
              "&:hover": {
                backgroundColor: "black",
                color: "white",
              },
              "&:disabled": {
                background: "rgba(0, 0, 0, 0.12)",
                border: "2px solid rgba(0, 0, 0, 0.12)",
              },
            }}
            startIcon={
              googleLoading ? (
                <CircularProgress size={20} color="inherit" />
              ) : (
                <Google
                  sx={{
                    width: iconSize,
                    height: iconSize,
                    mr: 0.5,
                  }}
                />
              )
            }
            onClick={handleGoogleSignIn}
            disabled={loading || googleLoading}
          >
            {googleLoading ? "Signing in..." : "Continue with Google"}
          </Button>

          <Typography
            sx={{
              fontSize: {
                xs: "4vw",
                sm: "2.5vw",
                md: "1.8vw",
                lg: "1.25vw",
                xl: ".75vw",
              },
              fontFamily: "Poppins",
              fontWeight: 400,
              color: "black",
              textAlign: "center",
            }}
          >
            Don't have an account?{" "}
            <a href="/signup" style={{ color: "#2563eb", textDecoration: "underline" }}>
              Sign Up
            </a>
          </Typography>

          <Typography
            sx={{
              fontSize: {
                xs: "4vw",
                sm: "2.5vw",
                md: "1.8vw",
                lg: "1.25vw",
                xl: ".6vw",
              },
              fontFamily: "Poppins",
              fontWeight: 400,
              color: "gray",
              textAlign: "center",
            }}
          >
            By signing in, you agree to DeepTrain's{" "}
            <a href="/terms" style={{ color: "gray", textDecoration: "underline" }}>
              Terms of Service
            </a>{" "}
            and{" "}
            <a href="/privacy" style={{ color: "gray", textDecoration: "underline" }}>
              Privacy Policy
            </a>
          </Typography>
        </DialogContent>
      </Dialog>

      {/* Error Snackbar */}
      <Snackbar
        open={openError}
        autoHideDuration={6000}
        onClose={handleCloseError}
        anchorOrigin={{ vertical: "bottom", horizontal: "center" }}
      >
        <Alert onClose={handleCloseError} severity="error" sx={{ width: "100%" }}>
          {errorMessage}
        </Alert>
      </Snackbar>

      {/* Success Snackbar */}
      <Snackbar
        open={openSuccess}
        autoHideDuration={3000}
        onClose={handleCloseSuccess}
        anchorOrigin={{ vertical: "bottom", horizontal: "center" }}
      >
        <Alert onClose={handleCloseSuccess} severity="success" sx={{ width: "100%" }}>
          {successMessage}
        </Alert>
      </Snackbar>
    </>
  )
}
