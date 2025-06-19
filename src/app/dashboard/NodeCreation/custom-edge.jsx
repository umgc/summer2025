"use client"

import { useCallback } from "react"
import { BaseEdge, EdgeLabelRenderer, getBezierPath, useReactFlow } from "reactflow"

export default function CustomEdge({
  id,
  sourceX,
  sourceY,
  targetX,
  targetY,
  sourcePosition,
  targetPosition,
  data,
  style = {},
  markerEnd,
}) {
  const [edgePath, labelX, labelY] = getBezierPath({
    sourceX,
    sourceY,
    sourcePosition,
    targetX,
    targetY,
    targetPosition,
  })

  const { setEdges } = useReactFlow()

  const onEdgeClick = useCallback(
    (evt, id) => {
      evt.stopPropagation()
      setEdges((edges) => edges.filter((edge) => edge.id !== id))
    },
    [setEdges],
  )

  return (
    <>
      <BaseEdge path={edgePath} markerEnd={markerEnd} style={style} />
      <EdgeLabelRenderer>
        {data?.label && (
          <div
            style={{
              position: "absolute",
              transform: `translate(-50%, -50%) translate(${labelX}px,${labelY}px)`,
              background: "white",
              padding: "4px 8px",
              borderRadius: 4,
              fontSize: 12,
              fontWeight: 500,
              pointerEvents: "all",
              border: "1px solid #e2e8f0",
            }}
            className="nodrag nopan"
          >
            {data.label}
          </div>
        )}
      </EdgeLabelRenderer>
    </>
  )
}
