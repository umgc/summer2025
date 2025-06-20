import React, { useState } from 'react';
import { Typography, Box, Divider, MenuItem, Select, FormControl, InputLabel, Button, Dialog, DialogTitle, DialogContent, DialogActions, TextField } from '@mui/material';

// Custom Components
import CreateReviewDialog from './CreateReview';
import AnimatedButton from '@/app/GlobalComponents/AnimatedButtonDialog';

export default function ReviewsHeader({ reviews, setReviews, data, user }) {
    const [sortOption, setSortOption] = useState('highestRating');
    const [openDialog, setOpenDialog] = useState(false);

    const sort = (sortOption) => {
        let sorted;
        if (sortOption === 'highestRating') {
            sorted = [...reviews].sort((a, b) => b.rating - a.rating);
        } else if (sortOption === 'lowestRating') {
            sorted = [...reviews].sort((a, b) => a.rating - b.rating);
        } else {
            sorted = [...reviews].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
        }
        //console.log("Sorted:", sorted)
        setReviews(sorted);
    };

    // Handle sort change
    const handleSortChange = (event) => {
        const newSortOption = event.target.value;
        setSortOption(newSortOption);
        sort(newSortOption); // Callback to parent component to sort reviews
    };

    const handleOpenDialog = () => setOpenDialog(true);
    const handleCloseDialog = () => setOpenDialog(false);

    const handleReviewSubmit = (newReview) => {
        // Submit new review or add it locally
        //console.log('New Review:', newReview);
        // Add to reviews array locally for demo (in real app, send to backend)
        setReviews(prev => [...prev, newReview]);
    };

    return (
        <Box sx={{ width: '100%', my: 2 }}>
            {/* Header with Divider */}
            <Box
                display="flex"
                alignItems="center"
                justifyContent="space-between"
                mb={2}
                flexDirection={{ xs: 'column', sm: 'row', lg: 'row' }}
            >
                {/* Reviews Text on Left */}
                <Typography
                    sx={{
                        textAlign: { xs: 'center', sm: 'center', lg: 'center' },
                        fontSize: {
                            xs: '8vw',
                            sm: '4vw',
                            md: '3vw',
                            lg: '2vw',
                            xl: '1.2vw',
                        },
                        fontFamily: 'Montserrat',
                        fontWeight: 600,
                        color: "black",
                        mb: { xs: 1, md: 0 }
                    }}
                >
                    Reviews ({reviews.length})
                </Typography>

                <Box
                    sx={{
                        display: { xs: 'flex', sm: 'inline' },
                        alignItems: 'left',
                        justifyContent: 'left',
                        flexDirection: { xs: 'column', sm: 'row', lg: 'row' },
                    }}
                >
                    <Button
                        variant="contained"
                        color="primary"
                        size='large'
                        onClick={handleOpenDialog}
                        sx={{
                            mr: { xs: 0, sm: 2 },
                            mb: { xs: 2, sm: 0 },
                            height: {
                                xs: '10vw',
                                sm: '6vw',
                                md: '4vw',
                                lg: '3vw',
                                xl: '1.75vw',
                            },
                            textAlign: 'center',
                        }}
                    >
                        Create Review
                    </Button>

                    {/* Sort Dropdown on Right */}
                    <FormControl variant="outlined" size="small">
                        <Select
                            value={sortOption}
                            onChange={handleSortChange}
                            sx={{
                                //minWidth: 150,
                                height: {
                                    xs: '10vw',
                                    sm: '6vw',
                                    md: '4vw',
                                    lg: '3vw',
                                    xl: '1.75vw',
                                },
                            }}
                        >
                            <MenuItem value="mostRecent">Most Recent</MenuItem>
                            <MenuItem value="highestRating">Highest Rating</MenuItem>
                            <MenuItem value="lowestRating">Lowest Rating</MenuItem>
                        </Select>
                    </FormControl>
                </Box>
            </Box>

            <Divider
                sx={{
                    backgroundColor: 'black',
                    height: '2px',
                    opacity: 1,
                }}
            />

            <CreateReviewDialog
                open={openDialog}
                onClose={handleCloseDialog}
                onSubmit={handleReviewSubmit}
                data={data}
                user={user}
            />
        </Box>
    );
}
