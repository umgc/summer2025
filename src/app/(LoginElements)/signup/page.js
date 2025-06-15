import {
    Box,
    Typography,
    Grid,
    Button,
    Tooltip,

} from "@mui/material";
import Image from "next/image";
import Link from "next/link";

// Custom Components
import SignupForm from "./SignupForm";

export default function SignupPage() {

    const logo = 'https://3vsrvtbwvqgcv6z1.public.blob.vercel-storage.com/DeepTrain_Logo_small.png';

    return (
        <Box
            sx={{
                height: "100%",
                width: "100%",
                backgroundColor: "#F0F0F0",
                p: "1vw",
                overflow: 'hidden',
            }}
        >
            <Grid container spacing={2}>
                <Grid size={5}>
                    <Tooltip title="Home Page">
                        <Link href="/" passHref>
                            <Box
                                sx={{
                                    cursor: 'pointer',
                                    display: 'flex',
                                    alignItems: 'center',
                                    width: '7vw',
                                    height: '3vw',
                                    position: 'relative',
                                    transition: 'transform 0.3s ease, font-size 0.3s ease',
                                    '&:hover': {
                                        transform: 'scale(1.2)',
                                    },
                                }}
                            >
                                <Image
                                    src={logo}
                                    alt="Logo"
                                    fill
                                    sizes="100vw"
                                    style={{
                                        objectFit: 'contain',
                                    }}
                                    priority
                                />
                            </Box>
                        </Link>
                    </Tooltip>
                    <SignupForm />
                </Grid>

                <Grid size={7}>
                    <Box
                        sx={{
                            position: "relative",
                            width: "100%",
                            height: {
                                xs: "50vw",
                                sm: "40vw",
                                md: "30vw",
                                lg: "25vw",
                                xl: "95vh",
                            },
                            //border: "1px solid black",
                        }}
                    >
                        <Image
                            src="https://3vsrvtbwvqgcv6z1.public.blob.vercel-storage.com/technology-human-touch.jpg" 
                            alt="About DeepTrain"
                            fill
                            sizes="100vw"
                            style={{
                                objectFit: "cover",
                                borderRadius: "25px",
                            }}
                            priority
                        />
                    </Box>
                </Grid>
            </Grid>
        </Box>
    );
}
