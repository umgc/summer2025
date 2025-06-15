"use client"

import { Container, Typography, Box, Grid, Card, CardContent } from "@mui/material"
import { motion } from "framer-motion"
import { Psychology, TrendingUp, Groups } from "@mui/icons-material"

const features = [
  {
    icon: Psychology,
    title: "AI-Powered Learning Paths",
    description:
      "Personalized curriculum that adapts to your learning style, pace, and goals using advanced machine learning algorithms.",
  },
  {
    icon: TrendingUp,
    title: "Real-Time Progress Tracking",
    description:
      "Monitor your advancement with detailed analytics, performance metrics, and intelligent insights to optimize your learning journey.",
  },
  {
    icon: Groups,
    title: "Seamless Team Integration",
    description:
      "Collaborate effectively with team members, share progress, and learn together in a unified development environment.",
  },
]

export default function FeaturesSection() {
  return (
    <Box sx={{ py: 12, backgroundColor: "#ffffff" }}>
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
            Powerful Features for Modern Learning
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
            Discover the tools and capabilities that make DeepTrain the ultimate platform for AI-driven education and
            professional development.
          </Typography>
        </motion.div>

        <Grid container spacing={4}>
          {features.map((feature, index) => (
            <Grid item xs={12} md={4} key={index}>
              <motion.div
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.2 }}
                viewport={{ once: true }}
                whileHover={{ y: -10 }}
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
                  <CardContent sx={{ p: 4, textAlign: "center" }}>
                    <Box
                      sx={{
                        width: 80,
                        height: 80,
                        borderRadius: "50%",
                        background: "linear-gradient(45deg, #2563eb, #7c3aed)",
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                        mx: "auto",
                        mb: 3,
                      }}
                    >
                      <feature.icon sx={{ fontSize: 40, color: "white" }} />
                    </Box>

                    <Typography
                      variant="h5"
                      component="h3"
                      gutterBottom
                      sx={{
                        color: "#1e293b",
                        fontWeight: 600,
                        mb: 2,
                      }}
                    >
                      {feature.title}
                    </Typography>

                    <Typography
                      variant="body1"
                      sx={{
                        color: "#64748b",
                        lineHeight: 1.7,
                      }}
                    >
                      {feature.description}
                    </Typography>
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
