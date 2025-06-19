"use client"
import { useState } from "react"
import {
    Box,
    TextField,
    Select,
    MenuItem,
    FormControl,
    InputLabel,
    Typography,
} from "@mui/material"

export default function DecisionInput({
    localData,
    handleChange
}) {
    return (
        <Box>
            <TextField
                fullWidth
                label="Condition Expression"
                value={localData.condition || ""}
                onChange={(e) => handleChange("condition", e.target.value)}
                placeholder='e.g., score > 70'
                helperText="Use JavaScript-like syntax for branching logic"
                sx={{ mb: 2 }}
            />

            <TextField
                fullWidth
                label="True Path Label"
                value={localData.trueLabel || "Yes"}
                onChange={(e) => handleChange("trueLabel", e.target.value)}
                sx={{ mb: 2 }}
            />

            <TextField
                fullWidth
                label="False Path Label"
                value={localData.falseLabel || "No"}
                onChange={(e) => handleChange("falseLabel", e.target.value)}
                sx={{ mb: 2 }}
            />

            <Typography variant="caption" color="text.secondary">
                The node will route based on whether the expression evaluates to true or false.
            </Typography>
        </Box>
    )
}
