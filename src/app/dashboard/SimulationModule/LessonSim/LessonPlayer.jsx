import React, { useState, useEffect } from 'react';
import YouTube from 'react-youtube';
import { extractYouTubeId } from '@/utils/extractYouTubeId';
import { Box, Typography } from '@mui/material';

export default function LessonPlayer({ node, onComplete, subHeight }) {
    const [videoId, setVideoId] = useState(null);
    const [error, setError] = useState(false);

    useEffect(() => {
        try {
            const id = extractYouTubeId(node.data.content);
            if (!id || typeof id !== 'string' || id.length < 5) throw new Error("Invalid video ID");
            setVideoId(id);
        } catch (err) {
            console.error("Video ID extraction error:", err);
            setError(true);
        }
    }, [node.data.content]);

    const handleError = (event) => {
        console.error("YouTube Player Error:", event);
        setError(true);
    };

    if (error) {
        return (
            <Box
                sx={{
                    width: '100%',
                    height: subHeight,
                    display: 'flex',
                    justifyContent: 'center',
                    alignItems: 'center',
                    backgroundColor: '#fbeaea',
                    borderRadius: '12px',
                    boxShadow: 4,
                }}
            >
                <Typography color="error" fontWeight="bold">
                    ⚠️ Failed to load video. Please verify the YouTube URL.
                </Typography>
            </Box>
        );
    }

    return (
        <Box
            sx={{
                position: 'relative',
                zIndex: 1,
                width: '100%',
                height: subHeight,
                '& iframe': {
                    width: '100%',
                    height: subHeight,
                },
            }}
        >
            {videoId && (
                <YouTube
                    videoId={videoId}
                    opts={{
                        width: '100%',
                        height: '100%',
                        playerVars: { autoplay: 1 },
                    }}
                    onEnd={onComplete}
                    onError={handleError}
                />
            )}
        </Box>
    );
}
