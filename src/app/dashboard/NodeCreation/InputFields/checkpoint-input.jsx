import { TextField, Switch, FormControlLabel, Typography } from "@mui/material";

export default function CheckpointInput({ localData, handleChange }) {
  return (
    <>
      <TextField
        fullWidth
        label="Checkpoint Title"
        value={localData.title || ""}
        onChange={(e) => handleChange("title", e.target.value)}
        sx={{ mb: 2 }}
      />

      <TextField
        fullWidth
        multiline
        rows={3}
        label="Checkpoint Note"
        value={localData.note || ""}
        onChange={(e) => handleChange("note", e.target.value)}
        placeholder="Add reflection note, instructions, or a milestone comment"
        sx={{ mb: 2 }}
      />

      <TextField
        fullWidth
        type="number"
        label="Estimated Time (minutes)"
        value={localData.estimatedTime || ""}
        onChange={(e) => handleChange("estimatedTime", e.target.value)}
        sx={{ mb: 2 }}
      />

      <FormControlLabel
        control={
          <Switch
            checked={localData.pause || false}
            onChange={(e) => handleChange("pause", e.target.checked)}
          />
        }
        label="Pause Flow Until Reviewed"
        sx={{ mb: 2 }}
      />

      <Typography variant="caption" color="text.secondary">
        Useful to track progress or add manual intervention checkpoints.
      </Typography>
    </>
  );
}
