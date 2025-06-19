"use client"

import { Button, Box, Typography } from "@mui/material"
import { 
  TouchApp, 
  Http, 
  AccountTree, 
  Code, 
  StopCircle, 
  Flag, 
  Quiz, 
  MenuBook, 
  PlayCircleOutline 
} from "@mui/icons-material"
import { color } from "framer-motion";

const nodeTypes = [
  {
    type: "start",
    label: "Start",
    description: "Entry point of the training flow",
    icon: <PlayCircleOutline sx={{ fontSize: 16, mr: 1 }} />,
    color: "#2e7d32",
  },
  {
    type: "lesson",
    label: "Lesson",
    description: "Instructional content (text, video, image)",
    icon: <MenuBook sx={{ fontSize: 16, mr: 1 }} />,
    color: "#2e86c1",
  },
  {
    type: "quiz",
    label: "Quiz",
    description: "Assessment with questions and scores",
    icon: <Quiz sx={{ fontSize: 16, mr: 1 }} />,
    color: "#7b1fa2",
  },
  {
    type: "decision",
    label: "Decision",
    description: "Branching logic based on input or scores",
    icon: <AccountTree sx={{ fontSize: 16, mr: 1 }} />,
    color: "#f5b041",
  },
  {
    type: "checkpoint",
    label: "Checkpoint",
    description: "Progress milestone or autosave point",
    icon: <Flag sx={{ fontSize: 16, mr: 1 }} />,
    color: "#1abc9c",
  },
  {
    type: "end",
    label: "End",
    description: "Marks the end of the training module",
    icon: <StopCircle sx={{ fontSize: 16, mr: 1 }} />,
    color: "#DC143C",
  },
  {
    type: "interactive",
    label: "Interactive",
    description: "Drag-and-drop or simulation interaction",
    icon: <TouchApp sx={{ fontSize: 16, mr: 1 }} />,
    color: "#f7dc6f",
    //disabled: true,
  },
  {
    type: "api",
    label: "API Action",
    description: "Trigger external API or webhook",
    icon: <Http sx={{ fontSize: 16, mr: 1 }} />,
    disabled: true,
  },
];


export default function NodeLibrary() {
  const onDragStart = (event, nodeType) => {
    event.dataTransfer.setData("application/reactflow", nodeType)
    event.dataTransfer.effectAllowed = "move"
  }

  return (
    <Box sx={{ display: "flex", flexDirection: "column", gap: 1 }}>
      {nodeTypes.map((node) => (
        <Button
          key={node.type}
          variant="outlined"
          color={node.color || "primary"}
          sx={{
            border: `3px solid ${node.color || "#1976d2"}`,
            justifyContent: "flex-start",
            textAlign: "left",
            opacity: node.disabled ? 0.5 : 1,
            cursor: node.disabled ? "not-allowed" : "grab",
            "&:active": {
              cursor: node.disabled ? "not-allowed" : "grabbing",
            },
          }}
          draggable={!node.disabled}
          onDragStart={(e) => onDragStart(e, node.type)}
          disabled={node.disabled}
        >
          {node.icon}
          <Box sx={{ display: "flex", flexDirection: "column", alignItems: "flex-start" }}>
            <Typography variant="body2" component="span">
              {node.label}
            </Typography>
            <Typography variant="caption" sx={{ color: "text.secondary" }}>
              {node.description}
            </Typography>
          </Box>
        </Button>
      ))}
      <Typography variant="caption" sx={{ mt: 2, color: "text.secondary" }}>
        Drag and drop nodes onto the canvas to build your workflow
      </Typography>
    </Box>
  )
}
