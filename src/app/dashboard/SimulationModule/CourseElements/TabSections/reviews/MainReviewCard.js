import React from 'react';
import { Card, Typography, Box, LinearProgress, useTheme, Grid } from '@mui/material';
import StarIcon from '@mui/icons-material/Star';
import StarOutlineIcon from '@mui/icons-material/StarOutline';
import StarHalfIcon from '@mui/icons-material/StarHalf';

export default function MainReviewCard({ reviews }) {
  const theme = useTheme();
  const bckgrdColor = theme.palette.background.default;
  const totalReviews = reviews.length;

  // Calculate the average rating, default to 0 if no reviews
  const averageRating = totalReviews > 0
    ? reviews.reduce((sum, review) => sum + review.rating, 0) / totalReviews
    : 0;

  // Calculate rating distribution for each star level
  const ratingLabels = [
    { label: "Excellent", color: "green" },
    { label: "Good", color: "lightgreen" },
    { label: "Average", color: "yellow" },
    { label: "Ok", color: "orange" },
    { label: "Poor", color: "red" },
  ];
  const ratingDistribution = [0, 0, 0, 0, 0];
  reviews.forEach((review) => {
    if (review.rating >= 1 && review.rating <= 5) {
      ratingDistribution[5 - review.rating] += 1;
    }
  });

  // Helper function to render average star rating
  const renderRating = (rating) => {
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 >= 0.5;
    const emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return (
      <>
        {[...Array(fullStars)].map((_, i) => (
          <StarIcon key={`full-${i}`} color="primary" fontSize="large" />
        ))}
        {hasHalfStar && <StarHalfIcon color="primary" fontSize="large" />}
        {[...Array(emptyStars)].map((_, i) => (
          <StarOutlineIcon key={`empty-${i}`} color="primary" fontSize="large" />
        ))}
      </>
    );
  };

  return (
    <Card
      sx={{
        p: 10,
        boxShadow: 0,
        backgroundColor: bckgrdColor,
        //borderBottom: '1px solid gray'
      }}
    >
      <Grid container spacing={0}>
        {/* Left Section: Average Rating */}
        <Grid          
          size={{ xs: 12, lg: 3 }}
          container
          direction="column"
          alignItems="center"
          justifyContent="center"
        >
          <Typography
            sx={{
              textAlign: 'center',
              fontSize: {
                xs: '9vw',
                sm: '4vw',
                md: '5vw',
                lg: '3vw'
              },
              fontFamily: 'Montserrat',
              fontWeight: 800,
              color: "black",
              mb: -1,
            }}
          >
            {averageRating.toFixed(1)}
          </Typography>
          <Box display="flex" alignItems="center" justifyContent="center" >
            {renderRating(averageRating)}
          </Box>
          <Typography
            sx={{
              textAlign: 'center',
              fontSize: {
                xs: '7vw',
                sm: '4vw',
                md: '4vw',
                lg: '1.2vw'
              },
              fontFamily: 'Montserrat',
              fontWeight: 600,
              color: "black",

            }}
          >
            Based on {totalReviews} reviews
          </Typography>
        </Grid>

        {/* Right Section: Rating Distribution */}
        <Grid container size={{ xs: 12, lg: 9 }}
          sx={{
            mt: { xs: 3, sm: 1 },
            display: 'flex',
            justifyContent: { xs: 'left', lg: 'center' },
            alignContent: 'center',
            flexDirection: 'row'
          }}
        >
          {ratingDistribution.map((count, index) => (
            <>
              <Grid
                item
                size={{
                  xs: 3,
                  sm: 3,
                  md: 2.5,
                  lg: 1
                }}
                key={index}
                sx={{
                  display: 'flex',
                  justifyContent: 'left',
                  alignItems: 'center',
                }}
              >
                <Typography
                  sx={{
                    textAlign: 'left',
                    fontSize: {
                      xs: '4vw',
                      sm: '3.5vw',
                      md: '3vw',
                      lg: '1.2vw'
                    },
                    fontFamily: 'Montserrat',
                    fontWeight: 600,
                    color: "black",
                  }}
                >
                  {ratingLabels[index].label}
                </Typography>
              </Grid>

              <Grid item
                size={{
                  xs: 7.5,
                  sm: 8,
                  md: 8.5,
                  lg: 10.5,
                }}
                key={index}
              >
                <Box
                  sx={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    width: '98%',
                    ml: { xs: 1, lg: 2 },
                    mt: { xs: 1.75, sm: 2.5, md: 3, lg: 1, xl: 3 },
                  }}
                >
                  <LinearProgress
                    variant="determinate"
                    value={(count / totalReviews) * 100}
                    sx={{
                      flex: 1,
                      height: 8,
                      borderRadius: 2,
                      backgroundColor: `${ratingLabels[index].color}40`, // Light background color
                      '& .MuiLinearProgress-bar': {
                        backgroundColor: ratingLabels[index].color, // Progress bar color
                      },
                    }}
                  />
                </Box>
              </Grid>
              <Grid
                item
                size={{ xs: 1.5, sm: 1, lg: .5 }}
                key={index}
              >
                <Typography
                  sx={{
                    textAlign: { xs: 'center', sm: 'center', lg: 'left' },
                    fontSize: {
                      xs: '6vw',
                      sm: '4vw',
                      md: '3vw',
                      lg: '1vw'
                    },
                    fontFamily: 'Montserrat',
                    fontWeight: 600,
                    color: "black",
                    //width: '10%'
                  }}
                >
                  {count}
                </Typography>
              </Grid>


            </>
          ))}
        </Grid>
      </Grid>
    </Card>
  );
}
