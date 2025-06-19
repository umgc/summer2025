"use client"

import { memo } from "react"
import { Handle, Position } from "reactflow"
import { Box, Typography, Chip } from "@mui/material"
import { MenuBook } from "@mui/icons-material"

export const ProcessNode = memo(({ data, isConnectable }) => {
  return (
    <Box
      sx={{
        px: 2,
        py: 1.5,
        boxShadow: 2,
        borderRadius: 1,
        bgcolor: "white",
        border: "2px solid #7b1fa2",
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
            bgcolor: "#f3e5f5",
            color: "#7b1fa2",
          }}
        >
          <MenuBook sx={{ fontSize: 16 }} />
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
        style={{ width: 12, height: 12, backgroundColor: "#7b1fa2" }}
      />
      <Handle
        type="source"
        position={Position.Bottom}
        isConnectable={isConnectable}
        style={{ width: 12, height: 12, backgroundColor: "#7b1fa2" }}
      />
    </Box>
  )
})

ProcessNode.displayName = "ProcessNode"
