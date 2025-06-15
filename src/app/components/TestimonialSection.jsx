"use client"

import { Container, Typography, Box, Grid, Card, CardContent, Avatar } from "@mui/material"
import { motion } from "framer-motion"
import { FormatQuote } from "@mui/icons-material"

const testimonials = [
  {
    name: "Sarah Chen",
    role: "Senior Developer",
    avatar: "/placeholder.svg?height=60&width=60",
    quote:
      "DeepTrain transformed how I approach learning new technologies. The AI-powered paths are incredibly intuitive and effective.",
  },
  {
    name: "Marcus Rodriguez",
    role: "Tech Lead",
    avatar: "/placeholder.svg?height=60&width=60",
    quote:
      "The real-time progress tracking keeps our entire team aligned and motivated. Best investment we've made in team development.",
  },
  {
    name: "Emily Watson",
    role: "Product Manager",
    avatar: "/placeholder.svg?height=60&width=60",
    quote:
      "Seamless integration with our workflow. DeepTrain makes continuous learning feel natural and engaging for everyone.",
  },
]

export default function TestimonialSection() {
  return (
    <Box sx={{ py: 12, backgroundColor: "#f8fafc" }}>
      <Container maxWidth="lg">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
        >
          <Typography
            variant="h2"
            component="h2"
            align="center"
            gutterBottom
            sx={{
              color: "#1e293b",
              mb: 2,
            }}
          >
            What Our Users Say
          </Typography>

          <Typography
            variant="h6"
            align="center"
            sx={{
              color: "#64748b",
              mb: 8,
              maxWidth: 600,
              mx: "auto",
            }}
          >
            Join thousands of professionals who have accelerated their careers with DeepTrain's AI-powered learning
            platform.
          </Typography>
        </motion.div>

        <Grid container spacing={4}>
          {testimonials.map((testimonial, index) => (
            <Grid size={4} key={index}>
              <motion.div
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.2 }}
                viewport={{ once: true }}
                whileHover={{ y: -5 }}
              >
                <Card
                  sx={{
                    height: "100%",
                    borderRadius: 3,
                    boxShadow: "0 4px 20px rgba(0, 0, 0, 0.08)",
                    transition: "all 0.3s ease",
                    "&:hover": {
                      boxShadow: "0 8px 30px rgba(0, 0, 0, 0.12)",
                    },
                  }}
                >
                  <CardContent sx={{ p: 4 }}>
                    <Box sx={{ mb: 3 }}>
                      <FormatQuote
                        sx={{
                          fontSize: 40,
                          color: "#2563eb",
                          opacity: 0.3,
                        }}
                      />
                    </Box>

                    <Typography
                      variant="body1"
                      sx={{
                        color: "#374151",
                        lineHeight: 1.7,
                        mb: 4,
                        fontStyle: "italic",
                      }}
                    >
                      "{testimonial.quote}"
                    </Typography>

                    <Box sx={{ display: "flex", alignItems: "center" }}>
                      <Avatar
                        src={testimonial.avatar}
                        sx={{
                          width: 50,
                          height: 50,
                          mr: 2,
                        }}
                      />
                      <Box>
                        <Typography
                          variant="h6"
                          sx={{
                            color: "#1e293b",
                            fontWeight: 600,
                          }}
                        >
                          {testimonial.name}
                        </Typography>
                        <Typography
                          variant="body2"
                          sx={{
                            color: "#64748b",
                          }}
                        >
                          {testimonial.role}
                        </Typography>
                      </Box>
                    </Box>
                  </CardContent>
                </Card>
              </motion.div>
            </Grid>
          ))}
        </Grid>
      </Container>
    </Box>
  )
}
