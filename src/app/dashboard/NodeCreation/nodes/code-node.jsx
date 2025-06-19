"use client"

import { memo } from "react"
import { Handle, Position } from "reactflow"
import { Box, Typography, Chip } from "@mui/material"
import { Code } from "@mui/icons-material"

export const CodeNode = memo(({ data, isConnectable }) => {
  return (
    <Box
      sx={{
        px: 2,
        py: 1.5,
        boxShadow: 2,
        borderRadius: 1,
        bgcolor: "white",
        border: "2px solid #616161",
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
            bgcolor: "#f5f5f5",
            color: "#616161",
          }}
        >
          <Code sx={{ fontSize: 16 }} />
        </Box>
        <Box sx={{ ml: 1 }}>
          <Typography variant="body2" sx={{ fontWeight: "bold" }}>
            {data.label || "Code"}
          </Typography>
          <Typography variant="caption" sx={{ color: "text.secondary" }}>
            {data.description || "Custom code execution"}
          </Typography>
        </Box>
      </Box>

      {data.codeLanguage && (
        <Chip label={`Language: ${data.codeLanguage}`} size="small" sx={{ mt: 1, fontSize: "0.75rem" }} />
      )}

      <Handle
        type="target"
        position={Position.Top}
        isConnectable={isConnectable}
        style={{ width: 12, height: 12, backgroundColor: "#616161" }}
      />
      <Handle
        type="source"
        position={Position.Bottom}
        isConnectable={isConnectable}
        style={{ width: 12, height: 12, backgroundColor: "#616161" }}
      />
    </Box>
  )
})

CodeNode.displayName = "CodeNode"
