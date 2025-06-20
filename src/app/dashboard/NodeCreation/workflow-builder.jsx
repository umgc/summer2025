"use client"

import { useState, useCallback, useRef } from "react"
import ReactFlow, {
  ReactFlowProvider,
  Background,
  Controls,
  MiniMap,
  addEdge,
  Panel,
  useNodesState,
  useEdgesState,
} from "reactflow"
import "reactflow/dist/style.css"
import { Button, Snackbar, Alert, Box, ThemeProvider, createTheme } from "@mui/material"
import { Save, Upload, PlayArrow } from "@mui/icons-material"
import NodeLibrary from "./node-library"
import NodeConfigPanel from "./node-config-panel"
import CustomEdge from "./custom-edge"

import { generateNodeId, createNode } from "@/lib/workflow-utils"

const theme = createTheme({
  palette: {
    primary: {
      main: "#1976d2",
    },
    secondary: {
      main: "#dc004e",
    },
  },
})


//Node Imports
import { InputNode } from "./nodes/input-node"
import { OutputNode } from "./nodes/output-node"
import { ProcessNode } from "./nodes/process-node"
import { ConditionalNode } from "./nodes/conditional-node"
import { CodeNode } from "./nodes/code-node"
import { LessonNode } from "./nodes/lesson-node"
import { QuizNode } from "./nodes/quiz-node"
import { DecisionNode } from "./nodes/decision-node"
import { StartNode } from "./nodes/start-node"
import { InteractiveNode } from "./nodes/interactive-node"
import { CheckpointNode } from "./nodes/checkpoint-node"

const nodeTypes = {
  input: InputNode,
  output: OutputNode,
  process: ProcessNode,
  conditional: ConditionalNode,
  code: CodeNode,
  start: StartNode,
  lesson: LessonNode,
  quiz: QuizNode,
  decision: DecisionNode,
  checkpoint: CheckpointNode,
  end: OutputNode,
  interactive: InteractiveNode,
}

const edgeTypes = {
  custom: CustomEdge,
}

export default function WorkflowBuilder({
  nodes, setNodes, onNodesChange,
  edges, setEdges, onEdgesChange,
  user,
  snackbar, setSnackbar,
  showSnackbar, handleCloseSnackbar,
}) {
  const reactFlowWrapper = useRef(null)
  const [selectedNode, setSelectedNode] = useState(null)
  const [reactFlowInstance, setReactFlowInstance] = useState(null)

  const onConnect = useCallback(
    (params) => {
      const { sourceHandle } = params;
      let label = '';

      if (sourceHandle === 'pass') label = 'Pass';
      else if (sourceHandle === 'fail') label = 'Fail';

      setEdges((eds) =>
        addEdge(
          {
            ...params,
            type: 'custom',
            label,               
            data: { label },   
          },
          eds
        )
      );
    },
    [setEdges]
  );


  const onDragOver = useCallback((event) => {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }, [])

  const onDrop = useCallback(
    (event) => {
      event.preventDefault()

      const reactFlowBounds = reactFlowWrapper.current?.getBoundingClientRect()
      const type = event.dataTransfer.getData("application/reactflow")

      if (typeof type === "undefined" || !type) {
        return
      }

      if (reactFlowBounds && reactFlowInstance) {
        const position = reactFlowInstance.screenToFlowPosition({
          x: event.clientX - reactFlowBounds.left,
          y: event.clientY - reactFlowBounds.top,
        })

        const newNode = createNode({
          type,
          position,
          id: generateNodeId(type),
        })

        setNodes((nds) => nds.concat(newNode))
      }
    },
    [reactFlowInstance, setNodes],
  )

  const onNodeClick = useCallback((_, node) => {
    setSelectedNode(node)
  }, [])

  const onPaneClick = useCallback(() => {
    setSelectedNode(null)
  }, [])

  const updateNodeData = useCallback(
    (nodeId, data) => {
      setNodes((nds) =>
        nds.map((node) => {
          if (node.id === nodeId) {
            return {
              ...node,
              data: {
                ...node.data,
                ...data,
              },
            }
          }
          return node
        }),
      )
    },
    [setNodes],
  )

  return (
    <ThemeProvider theme={theme}>
      <Box sx={{ display: "flex", height: "77vh" }}>
        <Box sx={{ width: 256, borderRight: "1px solid #e0e0e0", p: 2, bgcolor: "#f5f5f5" }}>
          <h2 style={{ fontSize: "1.125rem", fontWeight: 600, marginBottom: "1rem" }}>Node Library</h2>
          <NodeLibrary />
        </Box>

        <Box sx={{ flex: 1, display: "flex", flexDirection: "column" }}>
          <Box sx={{ flex: 1 }} ref={reactFlowWrapper}>
            <ReactFlowProvider>
              <ReactFlow
                nodes={nodes}
                edges={edges}
                onNodesChange={onNodesChange}
                onEdgesChange={onEdgesChange}
                onConnect={onConnect}
                onInit={setReactFlowInstance}
                onDrop={onDrop}
                onDragOver={onDragOver}
                onNodeClick={onNodeClick}
                onPaneClick={onPaneClick}
                nodeTypes={nodeTypes}
                edgeTypes={edgeTypes}
                fitView
                snapToGrid
                snapGrid={[15, 15]}
                defaultEdgeOptions={{ type: "custom", updatable: true}}
              >
                <Background />
                <Controls />
                <MiniMap />
              </ReactFlow>
            </ReactFlowProvider>
          </Box>
        </Box>

        {selectedNode && (
          <Box sx={{ width: 320, borderLeft: "1px solid #e0e0e0", p: 2, bgcolor: "#f5f5f5" }}>
            <NodeConfigPanel
              node={selectedNode}
              updateNodeData={updateNodeData}
              onClose={() => setSelectedNode(null)}
            />
          </Box>
        )}

        <Snackbar
          open={snackbar.open}
          autoHideDuration={6000}
          onClose={handleCloseSnackbar}
          anchorOrigin={{ vertical: "bottom", horizontal: "center" }}
        >
          <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} sx={{ width: "100%" }}>
            {snackbar.message}
          </Alert>
        </Snackbar>
      </Box>
    </ThemeProvider>
  )
}
