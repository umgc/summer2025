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
  Grid
} from '@mui/material';

//Icons
import { ArrowOutward } from '@mui/icons-material';

//Custom Components
import ReviewCard from './ReviewerCard';
import MainReviewCard from './MainReviewCard';
import ReviewsHeader from './ReviewsHeader';

const CourseReviews = ({ data, courseLoading, user }) => {
  const theme = useTheme();
  const bckgrdColor = theme.palette.background.default;
  const [reviews, setReviews] = useState([]);

  useEffect(() => {
    if (data && data.reviews) {
      setReviews(data.reviews);
    }
  }, [data]);

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
      {user ? (
        <Grid
          container
          sx={{
            py: 2,
            px: { xs: 3, sm: 5 },
            position: 'relative',
          }}
          spacing={{ xs: 0, sm: 2 }}
        >
          <Grid
            size={12}
          >
            <MainReviewCard reviews={reviews} />
          </Grid>

          <Grid
            size={12}
            sx={{
              px: { xs: 2, md: 5 },
            }}
          >
            <ReviewsHeader
              reviews={reviews}
              setReviews={setReviews}
              data={data}
              user={user}
            />
          </Grid>

          {reviews.map((review) => (
            <Grid
              size={12}
              key={review.id}
              sx={{
                px: { xs: 2, md: 5, lg: 10 },
              }}
            >
              <ReviewCard review={review} />
            </Grid>
          ))}
        </Grid>
      ) : (
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
          }}
        >
          <Typography
            sx={{
              textAlign: "center",
              fontSize: {
                xs: '8vw',
                sm: '4vw',
                md: '3vw',
                lg: '2vw',
                xl: '1.25vw',
              },
              fontFamily: 'Poppins',
              fontWeight: 600,
              color: "black",
            }}
          >
            Please log in to view reviews
          </Typography>
        </Box>
      )}
    </Box>
  );
};

export default CourseReviews;
