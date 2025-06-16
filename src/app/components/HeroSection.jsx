"use client"

import { Container, Typography, Button, Box, Grid, Tooltip } from "@mui/material"
import { motion } from "framer-motion"
import { ArrowForward, PlayArrow } from "@mui/icons-material"

import Image from 'next/image';

export default function HeroSection() {

  const logoHero = "https://3vsrvtbwvqgcv6z1.public.blob.vercel-storage.com/DeepTrainHero.png"
  
  return (
    <Box
      sx={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        background: "linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%)",
        position: "relative",
        overflow: "hidden",
        pt: { xs: 12, md: 8 }, // Add top padding for floating header
      }}
    >
      {/* Background decoration */}
      <Box
        sx={{
          position: "absolute",
          top: 0,
          right: 0,
          width: "50%",
          height: "100%",
          background: "linear-gradient(45deg, rgba(37, 99, 235, 0.1), rgba(124, 58, 237, 0.1))",
          borderRadius: "50% 0 0 50%",
          transform: "translateX(25%)",
        }}
      />

      <Container maxWidth="xl" sx={{ position: "relative", zIndex: 1 }}>
        <Grid container spacing={4} alignItems="center">          

          <Grid size={6}>
            <motion.div initial={{ opacity: 0, y: 50 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8 }}>
              <Typography
                variant="h1"
                component="h1"
                gutterBottom
                sx={{
                textAlign: "left",
                  color: "#1e293b",
                  mb: 3,
                  
                }}
              >
                Unlock Your Potential with{" "}
                <Box
                  component="span"
                  sx={{
                  textAlign: "left",
                    background: "linear-gradient(45deg, #2563eb, #7c3aed)",
                    backgroundClip: "text",
                    WebkitBackgroundClip: "text",
                    WebkitTextFillColor: "transparent",
                  }}
                >
                  AI-Driven Training
                </Box>
              </Typography>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              <Typography
                sx={{
                  textAlign: "left",
                  color: "#64748b",
                  mb: 4,
                  lineHeight: 1,
                  fontWeight: 400,
                  fontFamily: 'Poppins',
                  fontSize: {
                      xs: '1.1vw',
                      sm: '1.2vw',
                      md: '1.3vw',
                      lg: '1.4vw',
                      xl: '1.2vw',
                  },
                  maxWidth: "90%",
                }}
              >
                Transform your learning journey with personalized AI-powered education and cutting-edge development
                tools designed for modern professionals.
              </Typography>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
            >
              <Box sx={{ display: "flex", gap: 2, flexWrap: "wrap" }}>
                <Button
                  variant="contained"
                  size="large"
                  endIcon={<ArrowForward />}
                  sx={{
                    background: "linear-gradient(45deg, #2563eb, #1d4ed8)",
                    px: 4,
                    py: 1.5,
                    fontSize: "1.1rem",
                    "&:hover": {
                      transform: "translateY(-2px)",
                      boxShadow: "0 8px 25px rgba(37, 99, 235, 0.4)",
                    },
                    transition: "all 0.3s ease",
                  }}
                >
                  Get Started
                </Button>

                {/*<Button
                  variant="outlined"
                  size="large"
                  startIcon={<PlayArrow />}
                  sx={{
                    borderWidth: 2,
                    px: 4,
                    py: 1.5,
                    fontSize: "1.1rem",
                    "&:hover": {
                      borderWidth: 2,
                      transform: "translateY(-2px)",
                      boxShadow: "0 4px 12px rgba(37, 99, 235, 0.2)",
                    },
                    transition: "all 0.3s ease",
                  }}
                >
                  Watch Demo
                </Button>*/}
              </Box>
            </motion.div>
          </Grid>

          <Grid size={6}
            sx={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              }}
          >
            <Tooltip title="Home Page">                
                  <Box
                    sx={{
                      //cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      width: '100%',
                      height: '40vw',
                      position: 'relative',
                      transition: 'transform 0.3s ease, font-size 0.3s ease',
                      //borderRadius: "0px 0px 999px 0px"
                      '&:hover': {
                        transform: 'scale(1)',
                      },
                    }}
                  >
                    <Image
                      src={logoHero}
                      alt="Logo Hero"
                      fill
                      sizes="100vw"
                      style={{
                        objectFit: 'contain',
                        //borderRadius: "0px 10% 10% 0px"
                      }}
                      priority
                    />
                  </Box>                
              </Tooltip>
          </Grid>

          
        </Grid>
      </Container>
    </Box>
  )
}
