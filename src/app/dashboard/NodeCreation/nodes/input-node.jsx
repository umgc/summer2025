"use client"

import { memo } from "react"
import { Handle, Position } from "reactflow"
import { Box, Typography, Chip } from "@mui/material"
import { PlayCircle, Storage } from "@mui/icons-material"

export const InputNode = memo(({ data, isConnectable }) => {
  return (
    <Box
      sx={{
        px: 2,
        py: 1.5,
        boxShadow: 2,
        borderRadius: 1,
        bgcolor: "white",
        border: "2px solid #2e7d32",
        minWidth: 150,
      }}
    >
      <Box sx={{ display: "flex", alignItems: "center" }}>
        <Box
          sx={{
            borderRadius: "50%",
            width: 48,
            height: 32,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            bgcolor: "#e3f2fd",
            color: "#2e7d32",
          }}
        >
          <PlayCircle sx={{ fontSize: 16 }} />
        </Box>
        <Box sx={{ ml: 1 }}>
          <Typography variant="body2" sx={{ fontWeight: "bold" }}>
            {data.label || "Input"}
          </Typography>
          <Typography variant="caption" sx={{ color: "text.secondary" }}>
            {data.description || "Data input node"}
          </Typography>
        </Box>
      </Box>

      {data.dataSource && (
        <Chip label={`Source: ${data.dataSource}`} size="small" sx={{ mt: 1, fontSize: "0.75rem" }} />
      )}

      <Handle
        type="source"
        position={Position.Bottom}
        isConnectable={isConnectable}
        style={{ width: 12, height: 12, backgroundColor: "#2e7d32" }}
      />
    </Box>
  )
})

InputNode.displayName = "InputNode"
