"use client"
import { useState } from "react"
import {
    Box,
    TextField,
    Select,
    MenuItem,
    FormControl,
    InputLabel,
} from "@mui/material"

export default function LessonInput({
    localData,
    handleChange,
    node,
}) {

    return (
        <>
            <FormControl fullWidth sx={{ mb: 2 }}>
                <InputLabel>Lesson Type</InputLabel>
                <Select
                    value={node.data.lessonType || localData.lessonType || "text"}
                    label="Lesson Type"
                    onChange={(e) => handleChange("lessonType", e.target.value)}
                    MenuProps={{ disablePortal: true }}
                >
                    <MenuItem value="text">Text</MenuItem>
                    <MenuItem value="markdown">Markdown</MenuItem>
                    <MenuItem value="video">Video</MenuItem>
                    <MenuItem value="embed">Embed</MenuItem>
                </Select>
            </FormControl>
            {localData.lessonType === "video" || localData.lessonType === "embed" ? (
                <TextField
                    fullWidth
                    label="Video or Embed URL"
                    value={node.data.content || localData.content || ""}
                    onChange={(e) => handleChange("content", e.target.value)}
                    placeholder="https://www.youtube.com/embed/..."
                    sx={{ mb: 2 }}
                />
            ) : (
                <TextField
                    fullWidth
                    multiline
                    rows={6}
                    label="Lesson Content"
                    value={node.data.content || localData.content || ""}
                    onChange={(e) => handleChange("content", e.target.value)}
                    placeholder="Write lesson instructions or markdown here"
                    sx={{ mb: 2 }}
                />
            )}
            <TextField
                fullWidth
                label="Estimated Time (minutes)"
                type="number"
                value={node.data?.duration || localData.duration || ""}
                onChange={(e) => handleChange("duration", e.target.value)}
                sx={{ mb: 2 }}
            />
        </>
    )
}
