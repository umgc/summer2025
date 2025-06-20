import React, { useEffect, useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  CardMedia,
  Typography,
  useTheme,
  Button,
  Divider,
  Skeleton,
  Grid,
} from '@mui/material';

const SkeletonProductReviews = () => {
  const theme = useTheme();
  const bckgrdColor = theme.palette.background.default;

  return (
    <Box
      sx={{
        position: 'relative',
        width: '100%',
        height: 'auto',
        backgroundColor: bckgrdColor,
        py: 5,
      }}
    >
      <Grid
        container
        sx={{
          py: 2,
          px: 5,
          position: 'relative',
        }}
        spacing={2}
      >
        <Grid 
          size={{
            xs: 12,
          }}
        >
          <Typography
            align="left"
            sx={{
              fontSize: {
                xs: '9vw',
                sm: '4vw',
                md: '5vw',
                lg: '5vw'
              },
              fontFamily: 'Montserrat',
              fontWeight: 600,
              color: "black",
              letterSpacing: '3px',
            }}
          >
            Customer Reviews
          </Typography>
        </Grid>

        <Grid size={12}>
          <Divider
            sx={{
              backgroundColor: 'black',
              height: '5px',
              opacity: 1,
              mt: -3,
              position: 'relative',
            }}
          />
        </Grid>

        <Grid
          
          size={4}
          sx={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            px: 15
          }}
        >
          <Skeleton
            variant="rounded"
            sx={{
              width: '100%',
              height: '20vh',
            }}
          />

        </Grid>
        <Grid
          
          size={8}
          sx={{
            pr: 10
          }}
        >
          <Skeleton
            variant="rounded"
            sx={{
              width: '100%',
              height: '20vh',
            }}
          />

        </Grid>

        <Grid
          
          size={12}
        >
          <Divider
            sx={{
              backgroundColor: 'black',
              height: '5px',
              opacity: 1,
              mt: 3,
              position: 'relative',
            }}
          />
        </Grid>
        {[...Array(4)].map((_, index) => (
          <Grid size={12} key={index} sx={{ px: 10 }}>
            <Skeleton
              variant="rounded"
              sx={{
                width: '100%',
                height: '15vh',
              }}
            />
          </Grid>
        ))}
      </Grid>
    </Box>
  );
};

export default SkeletonProductReviews;
