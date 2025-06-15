"use client"
import { useState } from "react"
import { Box } from "@mui/material"
import { useRouter } from "next/navigation"

//Icons
import { Phone, ArrowForward } from "@mui/icons-material"

//Custom
import AnimatedButton from "../../Buttons/AnimatedButton"
import SigninDialog from './SigninDialog';

export default function Signin({ tucked = false }) {
  const router = useRouter()
  const [signinOpen, setSigninOpen] = useState(false)

  const handleSigninOpen = () => {
    setSigninOpen(true)
  }

  const handleSignup = () => {
    router.push("/signup")
  }

  const handleClose = () => {
    setSigninOpen(false)
  }

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "row",
        justifyContent: "flex-end",
        gap: 2,
      }}
    >
      {/*<AnimatedButton
        color={tucked ? "white" : "#2563eb"}
        iconOnly={true}
        reverse={true}
        startIcon={<Phone />}
        borderRadius="999px"
        hoverTextColor={tucked ? "#2563eb" : "white"}
        size="large"
        border={`3px solid ${tucked ? "white" : "#2563eb"}`}
      />*/}

      <AnimatedButton
        color={tucked ? "white" : "#2563eb"}
         reverse={true}
        borderRadius="50px"
       hoverTextColor={tucked ? "#2563eb" : "white"}
        size="large"
        text="Log In"
        border={`3px solid ${tucked ? "white" : "#2563eb"}`}
        onclick={handleSigninOpen}
      />

      {/*<AnimatedButton
        color={tucked ? "white" : "#2563eb"}
        reverse={true}
        borderRadius="50px"
        hoverTextColor={tucked ? "#2563eb" : "white"}
        size="large"
        text="Get Started"
        border={`3px solid ${tucked ? "white" : "#2563eb"}`}
        endIcon={<ArrowForward />}
        onclick={handleSignup}
      />*/}

      <SigninDialog
                signinOpen={signinOpen}
                handleClose={handleClose}
            />
    </Box>
  )
}
