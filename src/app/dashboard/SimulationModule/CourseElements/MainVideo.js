"use client"
import * as React from "react"
import {
    Box,
    Skeleton,
} from "@mui/material"
//import MuxPlayer from '@mux/mux-player-react';

export default function MainVideoElement({ data, maxheight }) {

    return (
        <Box
            sx={{
                //aspectRatio: "16/9",
                height: maxheight,
                width: "100%",
                //bgcolor: "black",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                position: "relative",
                overflow: "hidden",
            }}
        >
            {data.video_playback_id !== null && data.video_playback_id !== undefined ? (
                <Box sx={{ zIndex: 1, width: "100%", height: "100%", bgcolor: "black", }}>
                    {/*<MuxPlayer
                        playbackId={data?.video_playback_id}
                        metadata={{
                            video_title: data.course_name || 'Missing Video Title',
                            //viewer_user_id: 'Placeholder (optional)',
                        }}
                        style={{ width: "100%", height: "100%" }}
                    />*/}
                </Box>
            ) : (
                <Box sx={{ zIndex: 1, width: "100%", height: "100%" }}>
                    <Skeleton
                        variant="rectangular"
                        animation="wave"
                        sx={{
                            width: "100%",
                            height: maxheight
                        }}
                    />
                </Box>
            )}
        </Box>
    );
}