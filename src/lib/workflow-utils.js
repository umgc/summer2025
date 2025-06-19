let nodeIdCounter = 0

export const generateNodeId = (type) => {
  nodeIdCounter++
  return `${type}-${nodeIdCounter}`
}

export const createNode = ({ type, position, id }) => {
  const baseNode = {
    id,
    type,
    position,
    data: {
      label: getDefaultLabel(type),
      description: getDefaultDescription(type),
    },
  }

  switch (type) {
    case "input":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          dataSource: "manual",
          sampleData: '{"example": "data"}',
        },
      }
    case "output":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          outputType: "console",
          outputFormat: "json",
        },
      }
    case "process":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          processType: "transform",
          processConfig: '{"operation": "map"}',
        },
      }
    case "conditional":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          condition: "data.value > 0",
          trueLabel: "Yes",
          falseLabel: "No",
        },
      }
    case "code":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          codeLanguage: "javascript",
          code: "// Write your code here\nfunction process(data) {\n  // Transform data\n  return data;\n}",
        },
      }
    case "lesson":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          content: "", // lesson content (text, markdown, or video link)
        },
      };
    case "quiz":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          questions: '[]', // JSON string for quiz questions
        },
      };
    case "decision":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          condition: "score > 70",
          trueLabel: "Yes",
          falseLabel: "No",
        },
      };
    case "checkpoint":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          note: "Checkpoint info here",
        },
      };
    case "end":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          endMessage: "Workflow completed",
        },
      };
    case "start":
      return {
        ...baseNode,
        type: "start", 
        data: {
          ...baseNode.data,
          label: "Start",
          description: "Workflow start node",
        },
      };
      case "interactive":
      return {
        ...baseNode,
        data: {
          ...baseNode.data,
          note: "Interactive info here",
        },
      };
    default:
      return baseNode
  }
}

const getDefaultLabel = (type) => {
  switch (type) {
    case "input":
      return "Input"
    case "output":
      return "Output"
    case "process":
      return "Process"
    case "conditional":
      return "Conditional"
    case "code":
      return "Code"
    case "lesson":
      return "Lesson";
    case "quiz":
      return "Quiz";
    case "decision":
      return "Decision";
    case "checkpoint":
      return "Checkpoint";
    case "end":
      return "End";
    case "start":
      return "Start";
    case "interactive":
      return "Interactive";
    default:
      return "Node"
  }
}

const getDefaultDescription = (type) => {
  switch (type) {
    case "input":
      return "Data input node"
    case "output":
      return "Data output node"
    case "process":
      return "Data processing node"
    case "conditional":
      return "Conditional branching"
    case "code":
      return "Custom code execution"
    case "lesson":
      return "Educational lesson node";
    case "quiz":
      return "Multiple choice or assessment quiz";
    case "decision":
      return "Conditional routing based on logic";
    case "checkpoint":
      return "Progress milestone";
    case "end":
      return "Workflow end node";
    case "start":
      return "Workflow start node";
    case "interactive":
      return "Interactive node for user input";
    default:
      return "Workflow node"
  }
}
