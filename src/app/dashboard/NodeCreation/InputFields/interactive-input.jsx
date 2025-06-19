import {
  TextField,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  FormControlLabel,
  Switch,
  Typography,
  Box,
} from "@mui/material";

export default function InteractiveInput({ localData, handleChange }) {
  return (
    <Box>
      <TextField
        fullWidth
        label="Prompt"
        value={localData.prompt || ""}
        onChange={(e) => handleChange("prompt", e.target.value)}
        placeholder="What do you want the user to answer?"
        sx={{ mb: 2 }}
      />

      <FormControl fullWidth sx={{ mb: 2 }}>
        <InputLabel>Input Type</InputLabel>
        <Select
          value={localData.inputType || "text"}
          label="Input Type"
          onChange={(e) => handleChange("inputType", e.target.value)}
          MenuProps={{disablePortal: true}}
        >
          <MenuItem value="text">Text</MenuItem>
          <MenuItem value="multiple-choice">Multiple Choice</MenuItem>
          <MenuItem value="dropdown">Dropdown</MenuItem>
          <MenuItem value="file">File Upload</MenuItem>
          <MenuItem value="slider">Slider (1–10)</MenuItem>
        </Select>
      </FormControl>

      {["multiple-choice", "dropdown"].includes(localData.inputType) && (
        <TextField
          fullWidth
          label="Options (comma-separated)"
          value={localData.options || ""}
          onChange={(e) => handleChange("options", e.target.value)}
          placeholder="Option 1, Option 2, Option 3"
          sx={{ mb: 2 }}
        />
      )}

      <FormControlLabel
        control={
          <Switch
            checked={localData.required || false}
            onChange={(e) => handleChange("required", e.target.checked)}
          />
        }
        label="Response Required"
        sx={{ mb: 2 }}
      />

      <Typography variant="caption" color="text.secondary">
        This node waits for user input before continuing.
      </Typography>
    </Box>
  );
}
