import {
    Box,
    Typography,
    Grid,
    Button,
    Tooltip,
} from "@mui/material";
import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";

// Custom Components
import ResetPasswordForm from "./ResetPasswordForm";

export default function ResetPasswordPage() {

    const logo = 'https://wyysdyllyizcnk1u.public.blob.vercel-storage.com/logos/DeepTrain_logo_tmp_small.png';

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

                    <Suspense fallback={null}>
                        <ResetPasswordForm />
                    </Suspense>

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
                            src="https://wyysdyllyizcnk1u.public.blob.vercel-storage.com/background/pexels-lkloeppel-2416654.jpg" // replace with your image path
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
