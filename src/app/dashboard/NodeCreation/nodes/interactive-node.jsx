"use client"

import { memo } from "react"
import { Handle, Position } from "reactflow"
import { Box, Typography, Chip } from "@mui/material"
import { TouchApp } from "@mui/icons-material"

export const InteractiveNode = memo(({ data, isConnectable }) => {
  return (
    <Box
      sx={{
        px: 2,
        py: 1.5,
        boxShadow: 2,
        borderRadius: 1,
        bgcolor: "white",
        border: "2px solid #b7950b",
        minWidth: 150,
      }}
    >
      <Box sx={{ display: "flex", alignItems: "center" }}>
        <Box
          sx={{
            borderRadius: "50%",
            width: 32,
            height: 32,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            bgcolor: "#fef9e7",
            color: "#b7950b ",
          }}
        >
          <TouchApp sx={{ fontSize: 16 }} />
        </Box>
        <Box sx={{ ml: 1 }}>
          <Typography variant="body2" sx={{ fontWeight: "bold" }}>
            {data.label || "Process"}
          </Typography>
          <Typography variant="caption" sx={{ color: "text.secondary" }}>
            {data.description || "Data processing node"}
          </Typography>
        </Box>
      </Box>

      {data.processType && (
        <Chip label={`Process: ${data.processType}`} size="small" sx={{ mt: 1, fontSize: "0.75rem" }} />
      )}

      <Handle
        type="target"
        position={Position.Top}
        isConnectable={isConnectable}
        style={{ width: 12, height: 12, backgroundColor: "#b7950b " }}
      />
      <Handle
        type="source"
        position={Position.Bottom}
        isConnectable={isConnectable}
        style={{ width: 12, height: 12, backgroundColor: "#b7950b " }}
      />
    </Box>
  )
})

InteractiveNode.displayName = "InteractiveNode"
