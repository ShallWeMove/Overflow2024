import { Box, CircularProgress } from "@mui/material";

export const Loading = () => {
  return (
    <Box
    sx={{
      position: "fixed",
      top: "60%",
      left: "50%",
      width: "100px",
      height: "100px",
      transform: "translate(-50%, -50%)",
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
    }}
  >
    <CircularProgress color="secondary" />
  </Box>
  )
}