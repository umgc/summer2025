"use client"
import { useState, useEffect } from "react"
import { Box, Button, Avatar, Menu, MenuItem, Typography, Divider } from "@mui/material"
import { useRouter } from "next/navigation"

//Custom
import Signin from "../Signin/Signin"
import { getCurrentUser, signOut, onAuthStateChange } from "../../../utils/supabase/client"
import UserSection from "./UserSection"

export default function UserElements({ tucked = false }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [anchorEl, setAnchorEl] = useState(null)
  const router = useRouter()

  useEffect(() => {
    // Initial user check
    checkUser()

    // Listen for auth state changes
    const {
      data: { subscription },
    } = onAuthStateChange((event, session) => {
      if (event === "SIGNED_IN") {
        setUser(session?.user || null)
        setLoading(false)
      } else if (event === "SIGNED_OUT") {
        setUser(null)
        setLoading(false)
      } else if (event === "TOKEN_REFRESHED") {
        setUser(session?.user || null)
      }
    })

    // Cleanup subscription
    return () => {
      subscription?.unsubscribe()
    }
  }, [])

  const checkUser = async () => {
    try {
      const currentUser = await getCurrentUser()
      setUser(currentUser)
    } catch (error) {
      // Error is already handled in getCurrentUser, just set user to null
      setUser(null)
    } finally {
      setLoading(false)
    }
  }

  const handleMenuOpen = (event) => {
    setAnchorEl(event.currentTarget)
  }

  const handleMenuClose = () => {
    setAnchorEl(null)
  }

  const handleSignOut = async () => {
    try {
      const result = await signOut()
      if (result === true) {
        setUser(null)
        handleMenuClose()
        router.push("/")
        router.refresh()
      }
    } catch (error) {
      console.error("Error signing out:", error)
    }
  }

  const handleProfile = () => {
    handleMenuClose()
    router.push("/profile")
  }

  const handleDashboard = () => {
    handleMenuClose()
    router.push("/dashboard")
  }

  if (loading) {
    return (
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          justifyContent: "flex-end",
          alignItems: "center",
          gap: 2,
        }}
      >
        {/* Loading placeholder */}
        <Box sx={{ width: 100, height: 40 }} />
      </Box>
    )
  }

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "row",
        justifyContent: "flex-end",
        alignItems: "center",
        gap: 2,
      }}
    >
      {user ? (
        <UserSection
          user={user}
          handleSignOut={handleSignOut}
          handleMenuOpen={handleMenuOpen}
          handleProfile={handleProfile}
          handleDashboard={handleDashboard}
        />
      ) : (
        <Signin tucked={tucked} />
      )}
    </Box>
  )
}
