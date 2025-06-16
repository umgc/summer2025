"use client"

import { ThemeProvider, createTheme } from "@mui/material/styles"
import CssBaseline from "@mui/material/CssBaseline"
import HeroSection from "./components/HeroSection"
import FeaturesSection from "./components/FeaturesSection"
import TestimonialSection from "./components/TestimonialSection"
import Footer from "./Footer/Footer"

//Custom Components
import Header from "./Header/Header"

const theme = createTheme({
  palette: {
    primary: {
      main: "#2563eb",
      dark: "#1d4ed8",
    },
    secondary: {
      main: "#7c3aed",
    },
    background: {
      default: "#ffffff",
    },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontWeight: 700,
      fontSize: "3.5rem",
      lineHeight: 1.2,
      "@media (max-width:600px)": {
        fontSize: "2.5rem",
      },
    },
    h2: {
      fontWeight: 600,
      fontSize: "2.5rem",
      lineHeight: 1.3,
      "@media (max-width:600px)": {
        fontSize: "2rem",
      },
    },
    h3: {
      fontWeight: 600,
      fontSize: "1.5rem",
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: "none",
          borderRadius: 8,
          padding: "12px 24px",
          fontSize: "1rem",
          fontWeight: 600,
        },
      },
    },
  },
})

export default function Page() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Header />
      <HeroSection />
      <FeaturesSection />
      <TestimonialSection />
      <Footer />
    </ThemeProvider>
  )
}
