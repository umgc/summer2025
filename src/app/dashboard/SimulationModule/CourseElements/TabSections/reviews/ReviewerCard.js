import React from 'react';
import { Card, CardContent, Avatar, Typography, useMediaQuery, useTheme, Box, Grid } from '@mui/material';

import StarIcon from '@mui/icons-material/Star';
import StarOutlineIcon from '@mui/icons-material/StarOutline';

export default function ReviewCard({ review }) {
  
  const reviewerName = review?.firstName
    ? `${review.firstName} ${review.lastName?.charAt(0) || ''}.`
    : 'Anonymous';

  const theme = useTheme();
  const isXS = useMediaQuery(theme.breakpoints.down('sm'));

  // Helper function to render star rating
  const renderRating = (rating) => {
    const fullStars = Math.floor(rating);
    const emptyStars = 5 - fullStars;
    return (
      <Box
        sx={{
          display: 'flex',
          justifyContent: { xs: 'center', sm: 'flex-start' }, // Center on xs, left-align otherwise
          alignItems: 'center',
          //mt: { xs: 1, sm: 0 }, // Optional: Add spacing on xs
        }}
      >
        {[...Array(fullStars)].map((_, i) => (
          <StarIcon
            key={`full-${i}`}
            color="primary"
            sx={{
              fontSize: {
                xs: '9vw',
                sm: '4vw',
                md: '3vw',
                lg: '1.5vw',
                xl: '1.25vw'
              },
            }}
          />
        ))}
        {[...Array(emptyStars)].map((_, i) => (
          <StarOutlineIcon
            key={`empty-${i}`}
            color="primary" sx={{
              fontSize: {
                xs: '9vw',
                sm: '4vw',
                md: '3vw',
                lg: '1.5vw',
                xl: '1.25vw'
              },
            }}
          />
        ))}
      </Box>
    );
  };

  return (
    <Card
      sx={{
        p: { xs: 0, sm: 1 },
        mb: { xs: 3, sm: 0 },
        position: 'relative',
        boxShadow: 10,
      }}
    >

      <Grid container alignItems="center" spacing={{ xs: 0, sm: 1 }} >
        {/* Reviewer Avatar and Name */}
        <Grid
          size={{ xs: 12, sm: 4, md: 3, lg: 2 }}
          container
          direction={isXS ? "column" : "column"}
          alignItems="center"
          sx={{
            p: { xs: 3, sm: 3 }
          }}
        >
          <Avatar
            alt={reviewerName}
            aria-label={reviewerName}
            sx={{
              width: { xs: '20vw', sm: '8vw', md: '6vw', lg: '3vw' },
              height: { xs: '20vw', sm: '8vw', md: '6vw', lg: '3vw' },
              bgcolor: '#87CEEB',
              fontSize: {
                xs: '9vw',
                sm: '4vw',
                md: '3vw',
                lg: '1.5vw',
                xl: '1.25vw'
              },
            }}
          >
            {reviewerName.charAt(0).toUpperCase()}
          </Avatar>
          <Typography
            align="center"
            sx={{
              fontSize: {
                xs: '6vw',
                sm: '2.5vw',
                md: '2vw',
                lg: '1vw'
              },
              fontFamily: 'Montserrat',
              fontWeight: 600,
              color: "black",
            }}
          >
            {reviewerName}
          </Typography>
        </Grid>

        {/* Review Content */}
        <Grid
          size={{ xs: 12, sm: 8, md: 9, lg: 10 }}
          sx={{
            minHeight: { xs: 175, sm: 0 },
          }}

        >
          <CardContent>
            <Box
              sx={{
                display: 'flex',
                flexDirection: { xs: 'row', sm: 'row' },
                gap: 2,
              }}
            >
              {renderRating(review.rating)}
              <Typography
                //align="center" 
                sx={{
                  fontSize: {
                    xs: '9vw',
                    sm: '2.3vw',
                    md: '2vw',
                    lg: '1vw'
                  },
                  fontFamily: 'Montserrat',
                  fontWeight: 500,
                  color: "gray",
                }}
              >
                {new Date(review.created_at).toLocaleDateString()}
              </Typography>
            </Box>


            <Typography
              sx={{
                textAlign: { xs: 'center', sm: 'left' },
                fontSize: {
                  xs: '5vw',
                  sm: '2.5vw',
                  md: '2vw',
                  lg: '1.1vw'
                },
                fontFamily: 'Montserrat',
                fontWeight: 400,
                color: "black",
                mt: { xs: 1, sm: 0 }
              }}
            >
              {review.comment || 'No comment provided.'}
            </Typography>
          </CardContent>
        </Grid>
      </Grid>
    </Card >
  );
}
