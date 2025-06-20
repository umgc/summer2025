// CreateReviewDialog.js
import React, { useState } from 'react';
import {
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    TextField,
    Button,
    IconButton,
    Rating,
    Typography,
    Box,
    Divider,
    Snackbar,
    Alert
} from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';

export default function CreateReviewDialog({ open, onClose, onSubmit, data, user }) {
    const [newReview, setNewReview] = useState({
        rating: 0,
        body: '',
        id: data.id,
    });
    const [fieldErrors, setFieldErrors] = useState({});
    const [openSnackbar, setOpenSnackbar] = useState(false);
    const [snackbarMessage, setSnackbarMessage] = useState('');
    const [snackbarSeverity, setSnackbarSeverity] = useState('success');

    const handleReviewChange = (field, value) => {
        setNewReview(prevReview => ({ ...prevReview, [field]: value }));
    };

    async function submitReview(reviewData) {
        try {
            const response = await fetch('/api/create-course-review', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ reviewData, user, courseData: data }),
            });
            console.log("Resp:", response)

            if (response.ok) {
                console.log('Review created successfully');
                // Optionally, refresh reviews or close the dialog
            } else {
                const errorData = await response.json();
                console.error('Error creating review:', errorData);
            }
            return response;
        } catch (error) {
            console.error('Error submitting review:', error);
            return error;
        }
    }

    const handleSubmit = async () => {
        const errors = {};
        if (!newReview.rating || newReview.rating === 0) errors.rating = "Rating cannot be zero";
        //if (!newReview.body) errors.body = "Description is required";
        setFieldErrors(errors);

        if (Object.keys(errors).length === 0) {
            const resp = await submitReview(newReview);
            console.log("Response2:", resp)

            if (resp && resp.status === 409) {
                setSnackbarMessage('You have already submitted a review for this course.');
                setSnackbarSeverity('warning');
                setOpenSnackbar(true);
                return;
            } else if (resp && resp.status === 500) {
                setSnackbarMessage('Failed to submit review. Please try again later.');
                setSnackbarSeverity('error');
                setOpenSnackbar(true);
                return;
            } else {
                setSnackbarMessage('Review submitted successfully!');
                setSnackbarSeverity('success');
                setOpenSnackbar(true);
            }

            onSubmit(newReview);
        }
    };

    return (
        <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
            <DialogTitle>
                <Typography
                    sx={{
                        fontFamily: 'Poppins',
                        fontWeight: 400,
                        color: "black",
                        fontSize: {
                            xs: '4vw',
                            sm: '2.5vw',
                            md: '2vw',
                            lg: '1vw',
                            xl: '1vw',
                        },
                    }}
                >
                    Create a Review
                </Typography>

                <IconButton
                    aria-label="close"
                    onClick={onClose}
                    sx={{
                        position: 'absolute',
                        right: 8,
                        top: 8,
                        color: (theme) => theme.palette.grey[500],
                    }}
                >
                    <CloseIcon />
                </IconButton>
                <Divider />
            </DialogTitle>

            <DialogContent sx={{ pt: 0 }}>
                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'row',
                        justifyContent: 'left',
                        alignItems: 'center',
                        my: 0,
                    }}
                >
                    <Typography
                        component="legend"
                        sx={{
                            mr: 1,
                            fontFamily: 'Poppins',
                            fontWeight: 400,
                            color: "black",
                            fontSize: {
                                xs: '4vw',
                                sm: '2.5vw',
                                md: '2vw',
                                lg: '1vw',
                                xl: '0.75vw',
                            },
                        }}
                    >
                        Rating:
                    </Typography>
                    <Rating
                        name="half-rating"
                        precision={0.5}
                        value={newReview.rating}
                        onChange={(e, newValue) => handleReviewChange('rating', newValue)}
                        size='large'
                    />
                    {fieldErrors.rating && (
                        <Typography variant="body2" color="error" sx={{ ml: 2 }}>
                            {fieldErrors.rating}
                        </Typography>
                    )}
                </Box>

                <TextField
                    fullWidth
                    label="Review Description"
                    multiline
                    rows={4}
                    value={newReview.body}
                    onChange={(e) => handleReviewChange('body', e.target.value)}
                    margin="dense"
                    variant="outlined"
                    slotProps={{
                        inputLabel: { style: { color: 'rgba(0, 0, 0, 0.6)' } },
                        htmlInput: { style: { color: 'black' } },
                    }}
                    error={Boolean(fieldErrors.body)}
                    helperText={fieldErrors.body || ''}
                />
            </DialogContent>

            <DialogActions>
                <Button variant="contained" onClick={onClose} color="error">
                    Cancel
                </Button>
                <Button variant="contained" onClick={handleSubmit} color="success">
                    Submit
                </Button>
            </DialogActions>

            <Snackbar
                open={openSnackbar}
                autoHideDuration={6000}
                onClose={() => setOpenSnackbar(false)}
                anchorOrigin={{ vertical: 'Bottom', horizontal: 'center' }}
            >
                <Alert
                    severity={snackbarSeverity}
                    onClose={() => setOpenSnackbar(false)}
                    sx={{ width: '100%' }}
                >
                    {snackbarMessage}
                </Alert>
            </Snackbar>
        </Dialog>
    );
}
