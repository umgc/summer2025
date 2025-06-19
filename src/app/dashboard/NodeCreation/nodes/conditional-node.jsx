"use client"

import { memo } from "react"
import { Handle, Position } from "reactflow"
import { Box, Typography, Chip } from "@mui/material"
import { AccountTree } from "@mui/icons-material"

export const ConditionalNode = memo(({ data, isConnectable }) => {
  return (
    <Box
      sx={{
        px: 2,
        py: 1.5,
        boxShadow: 2,
        borderRadius: 1,
        bgcolor: "white",
        border: "2px solid #f57c00",
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
            bgcolor: "#fff3e0",
            color: "#f57c00",
          }}
        >
          <AccountTree sx={{ fontSize: 16 }} />
        </Box>
        <Box sx={{ ml: 1 }}>
          <Typography variant="body2" sx={{ fontWeight: "bold" }}>
            {data.label || "Conditional"}
          </Typography>
          <Typography variant="caption" sx={{ color: "text.secondary" }}>
            {data.description || "Conditional branching"}
          </Typography>
        </Box>
      </Box>

      {data.condition && (
        <Chip label={`Condition: ${data.condition}`} size="small" sx={{ mt: 1, fontSize: "0.75rem" }} />
      )}

      <Box sx={{ display: "flex", justifyContent: "space-between", mt: 1 }}>
        <Typography variant="caption" sx={{ color: "#2e7d32", fontSize: "0.75rem" }}>
          {data.trueLabel || "Yes"}
        </Typography>
        <Typography variant="caption" sx={{ color: "#d32f2f", fontSize: "0.75rem" }}>
          {data.falseLabel || "No"}
        </Typography>
      </Box>

      <Handle
        type="target"
        position={Position.Top}
        isConnectable={isConnectable}
        style={{ width: 12, height: 12, backgroundColor: "#f57c00" }}
      />
      <Handle
        type="source"
        position={Position.Bottom}
        id="true"
        style={{ left: "25%", width: 12, height: 12, backgroundColor: "#2e7d32" }}
        isConnectable={isConnectable}
      />
      <Handle
        type="source"
        position={Position.Bottom}
        id="false"
        style={{ left: "75%", width: 12, height: 12, backgroundColor: "#d32f2f" }}
        isConnectable={isConnectable}
      />
    </Box>
  )
})

ConditionalNode.displayName = "ConditionalNode"
