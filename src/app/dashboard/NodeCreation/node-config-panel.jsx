"use client"

import { useState } from "react"
import {
  Box,
  Typography,
  TextField,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Switch,
  FormControlLabel,
  IconButton,
  Paper,
} from "@mui/material"
import {
  Close,
  MenuBook,
  Quiz,
  AccountTree,
  Flag,
  StopCircle,
  Start,
} from "@mui/icons-material"
import CodeEditor from "./code-editor"

//Input Fields
import LessonInput from "./InputFields/lesson-input"
import StartInput from "./InputFields/start-input"
import QuizInput from "./InputFields/quiz-input"
import DecisionInput from "./InputFields/decision-input"
import CheckpointInput from "./InputFields/checkpoint-input"
import InteractiveInput from "./InputFields/interactive-input"

export default function NodeConfigPanel({ node, updateNodeData, onClose }) {
  const [localData, setLocalData] = useState({ ...node.data })

  const handleChange = (key, value) => {
    setLocalData((prev) => ({
      ...prev,
      [key]: value,
    }))
    updateNodeData(node.id, { [key]: value })
  }

  const renderInputFields = () => {
    switch (node.type) {
      case "start":
        return (
          <StartInput
            localData={localData}
            handleChange={handleChange}
          />
        )

      case "lesson":
        return (
          <LessonInput
            localData={localData}
            handleChange={handleChange}
            node={node}
          />
        )

      case "quiz":
        return (
          <QuizInput
            localData={localData}
            handleChange={handleChange}
            node={node}
          />
        )

      case "decision":
        return (
          <DecisionInput
            localData={localData}
            handleChange={handleChange}
            node={node}
          />
        )

      case "checkpoint":
        return (
          <CheckpointInput
            localData={localData}
            handleChange={handleChange}
            node={node}
          />
        )

      case "interactive":
        return (
          <InteractiveInput
            localData={localData}
            handleChange={handleChange}
          />
        )

      default:
        return null
    }
  }

  return (
    <Paper sx={{ height: "100%", display: "flex", flexDirection: "column", p: 0 }}>
      <Box
        sx={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          p: 2,
          borderBottom: "1px solid #e0e0e0",
        }}
      >
        <Typography variant="h6">Configure {node.data.label}</Typography>
        <IconButton onClick={onClose} size="small">
          <Close />
        </IconButton>
      </Box>

      <Box sx={{ p: 2, flex: 1, overflow: "auto" }}>
        <TextField
          fullWidth
          label="Label"
          value={node.data.label || ""}
          onChange={(e) => handleChange("label", e.target.value)}
          sx={{ mb: 2 }}
        />

        <TextField
          fullWidth
          multiline
          rows={2}
          label="Description"
          value={node.data.description || ""}
          onChange={(e) => handleChange("description", e.target.value)}
          placeholder="Describe what this node does"
          sx={{ mb: 2 }}
        />

        <FormControlLabel
          control={
            <Switch
              checked={localData.required || false}
              onChange={(e) => handleChange("required", e.target.checked)}
            />
          }
          label="Required Node"
          sx={{ mb: 2 }}
        />

        <Box sx={{ borderTop: "1px solid #e0e0e0", pt: 2, mt: 2 }}>
          {renderInputFields()}
        </Box>
      </Box>
    </Paper>
  )
}
