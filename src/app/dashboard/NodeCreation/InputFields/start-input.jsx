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

export default function StartInput({
    localData,
    handleChange
}) {
    return (
        <>
            <TextField
                fullWidth
                label="Welcome Message"
                value={localData.welcomeMessage || ""}
                onChange={(e) => handleChange("welcomeMessage", e.target.value)}
                placeholder="Welcome to this training session!"
                sx={{ mb: 2 }}
            />
            <FormControl fullWidth sx={{ mb: 2 }}>
                <InputLabel>Start Mode</InputLabel>
                <Select
                    value={localData.startMode || "manual"}
                    label="Start Mode"
                    onChange={(e) => handleChange("startMode", e.target.value)}
                    MenuProps={{ disablePortal: true }}
                >
                    <MenuItem value="manual">Manual</MenuItem>
                    <MenuItem value="auto">Auto (on load)</MenuItem>
                </Select>
            </FormControl>
        </>
    )
}
