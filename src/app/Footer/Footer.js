"use client"

import { Container, Typography, Box, Grid, Link, Divider } from "@mui/material"
import { motion } from "framer-motion"

const footerLinks = [
  { text: "About", href: "/about" },
  { text: "Contact", href: "/contact" },
  { text: "Privacy Policy", href: "/privacy" },
  { text: "Terms of Service", href: "/terms" },
]

export default function Footer() {
  return (
    <Box sx={{ backgroundColor: "#1e293b", color: "white", py: 8 }}>
      <Container maxWidth="lg">
        <Grid container spacing={4}>
          <Grid item xs={12} md={6}>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
              viewport={{ once: true }}
            >
              <Typography
                variant="h4"
                component="div"
                sx={{
                  fontWeight: 700,
                  background: "linear-gradient(45deg, #60a5fa, #a78bfa)",
                  backgroundClip: "text",
                  WebkitBackgroundClip: "text",
                  WebkitTextFillColor: "transparent",
                  mb: 2,
                }}
              >
                DeepTrain
              </Typography>

              <Typography
                variant="body1"
                sx={{
                  color: "#94a3b8",
                  lineHeight: 1.7,
                  maxWidth: 400,
                }}
              >
                Empowering professionals with AI-driven learning experiences and cutting-edge development tools for the
                future of work.
              </Typography>
            </motion.div>
          </Grid>

          <Grid item xs={12} md={6}>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              viewport={{ once: true }}
            >
              <Typography
                variant="h6"
                sx={{
                  color: "white",
                  fontWeight: 600,
                  mb: 3,
                }}
              >
                Quick Links
              </Typography>

              <Box sx={{ display: "flex", flexWrap: "wrap", gap: 3 }}>
                {footerLinks.map((link, index) => (
                  <Link
                    key={index}
                    href={link.href}
                    sx={{
                      color: "#94a3b8",
                      textDecoration: "none",
                      transition: "color 0.3s ease",
                      "&:hover": {
                        color: "#60a5fa",
                      },
                    }}
                  >
                    {link.text}
                  </Link>
                ))}
              </Box>
            </motion.div>
          </Grid>
        </Grid>

        <Divider sx={{ my: 4, borderColor: "#334155" }} />

        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          viewport={{ once: true }}
        >
          <Typography
            variant="body2"
            align="center"
            sx={{
              color: "#64748b",
            }}
          >
            © {new Date().getFullYear()} DeepTrain. All rights reserved.
          </Typography>
        </motion.div>
      </Container>
    </Box>
  )
}
