'use client';
import React from 'react';
import {
    Box,
    Typography,
    Grid,
    List,
    ListItem,
    ListItemText,
} from '@mui/material';

import { PieChart } from '@mui/x-charts/PieChart';

export default function QuestionVariety({ user }) {
    const questionData = [
        { id: 'Multiple Choice', value: 45, color: '#1976d2' },
        { id: 'True/False', value: 5, color: '#9c27b0' },
        { id: 'Short Open Answer', value: 40, color: '#f44336' },
        { id: 'Long Open Answer', value: 10, color: '#ff9800' },
    ];

    return (
        <Grid size={4} sx={{ height: '100%', }}>
            <Box
                sx={{
                    backgroundColor: '#f8f9f9',
                    borderRadius: '20px',
                    border: '3px solid #e0e0e0',
                    p: 2,
                    height: '100%',
                    display: 'flex',
                    flexDirection: 'row',
                    //justifyContent: 'space-between',
                    minHeight: '30vh',
                }}
            >
                <Box
                    sx={{
                        display: 'flex',
                        flexDirection: 'column',
                        //alignItems: 'center',
                        //justifyContent: 'space-between',
                        //mb: 2,
                    }}
                >
                    <Typography
                        sx={{
                            textAlign: "left",
                            color: "black",
                            fontWeight: 500,
                            fontFamily: 'Poppins',
                            fontSize: {
                                xs: '1.1vw',
                                sm: '1.2vw',
                                md: '1.3vw',
                                lg: '1.4vw',
                                xl: '1.2vw',
                            },
                        }}
                    >
                        Question Variety
                    </Typography>

                    {/* Left List */}
                    <Box 
                     sx={{
                        flex: 1,
                        display: 'flex',
                        justifyContent: 'flex-start',
                        alignItems: 'flex-start',
                    }}
                    >
                        <List dense>
                            {questionData.map((q) => (
                                <ListItem key={q.id}>
                                    <ListItemText
                                        primary={`${q.id}: ${q.value}%`}
                                        primaryTypographyProps={{
                                            fontFamily: 'Poppins',
                                            fontSize: '0.9vw',
                                            color: 'black',
                                        }}
                                    />
                                </ListItem>
                            ))}
                        </List>
                    </Box>
                </Box>


                {/* Right Pie Chart */}
                <Box
                    sx={{
                        flex: 1,
                        display: 'flex',
                        justifyContent: 'center',
                        alignItems: 'center',
                    }}
                >
                    <PieChart
                        series={[
                            {
                                data: questionData,
                                innerRadius: 30,
                                outerRadius: 150,
                                paddingAngle: 5,
                                cornerRadius: 5,
                                startAngle: -90,
                                endAngle: 270,
                            }
                        ]}
                        width={300}
                        height={325}
                    />
                </Box>

            </Box>
        </Grid>
    );
}
