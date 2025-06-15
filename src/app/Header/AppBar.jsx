import { Box, AppBar, Button, Toolbar, Grid, Tooltip, Typography } from "@mui/material"
import Link from "next/link"

const navItems = [
  { label: "Features", path: "/" },
  { label: "Pricing", path: "/" },
  { label: "About", path: "/" },
  { label: "Contact", path: "/" },
]

// Custom
import UserElements from "./UserElements/UserElements"

export default function AppBarHeader() {
  const textColor = "black"

  return (
    <Box
      sx={{
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      <AppBar
        component="nav"
        position="fixed"
        sx={{
          display: "flex",
          justifyContent: "center",
          backgroundColor: "white",
          boxShadow: "0 4px 20px rgba(0, 0, 0, 0.1)",
          pl: 3,
          py: 1,
          color: textColor,
          borderRadius: "999px",
          mx: "2vw", //Floating
          my: "1vw", //Floating
          width: "96%", //Floating
        }}
      >
        <Toolbar>
          <Grid
            container
            sx={{
              display: "flex",
              alignItems: "center",
              width: "100%",
              height: "100%",
            }}
          >
            <Grid
              size={3}
              sx={{
                display: "flex",
                justifyContent: "flex-start",
                alignItems: "center",
              }}
            >
              <Tooltip title="Home Page">
                <Link href="/" passHref>
                  <Box
                    sx={{
                      cursor: "pointer",
                      display: "flex",
                      alignItems: "center",
                      transition: "transform 0.3s ease",
                      "&:hover": {
                        transform: "scale(1.05)",
                      },
                    }}
                  >
                    <Box
                      component="span"
                      sx={{
                        fontSize: "2rem",
                        fontWeight: 700,
                        background: "linear-gradient(45deg, #2563eb, #7c3aed)",
                        backgroundClip: "text",
                        WebkitBackgroundClip: "text",
                        WebkitTextFillColor: "transparent",
                      }}
                    >
                      DeepTrain
                    </Box>
                  </Box>
                </Link>
              </Tooltip>
            </Grid>

            <Grid
              size={6}
              sx={{
                display: "flex",
                flexDirection: "row",
                justifyContent: "center",
                alignItems: "center",
              }}
            >
              <Box
                sx={{
                  display: "flex",
                  flexDirection: "row",
                  justifyContent: "center",
                  gap: 4,
                }}
              >
                {navItems.map((item, index) => (
                  <Link key={index} href={item.path} passHref>
                    <Button
                      sx={{
                        color: textColor,
                        textTransform: "none",
                        fontSize: "1rem",
                        fontWeight: 500,
                        "&:hover": {
                          backgroundColor: "rgba(37, 99, 235, 0.1)",
                          color: "#2563eb",
                        },
                        transition: "all 0.3s ease",
                      }}
                    >
                      <Typography
                        
                        sx={{
                          fontFamily: 'Poppins',
                          fontWeight: 600,
                          fontSize: {
                            xs: '1.1vw',
                            sm: '1.2vw',
                            md: '1.3vw',
                            lg: '1.4vw',
                            xl: '.9vw',
                          },
                          color: "black"
                        }}
                      >
                        {item.label}
                      </Typography>
                    </Button>
                  </Link>
                ))}
              </Box>
            </Grid>

            <Grid
              size={3}
              sx={{
                display: "flex",
                flexDirection: "row",
                justifyContent: "flex-end",
                alignItems: "center",
              }}
            >
              <UserElements />
            </Grid>
          </Grid>
        </Toolbar>
      </AppBar>
    </Box>
  )
}
