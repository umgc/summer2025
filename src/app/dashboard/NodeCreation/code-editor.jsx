"use client"
import { TextField } from "@mui/material"

export default function CodeEditor({ value, onChange, language = "javascript" }) {
  return (
    <TextField
      fullWidth
      multiline
      rows={10}
      value={value}
      onChange={(e) => onChange(e.target.value)}
      sx={{
        "& .MuiInputBase-input": {
          fontFamily: "monospace",
          fontSize: "0.875rem",
          whiteSpace: "pre",
        },
      }}
      spellCheck={false}
    />
  )
}
