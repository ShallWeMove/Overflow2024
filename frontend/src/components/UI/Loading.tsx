import { Box, CircularProgress } from "@mui/material";

export const Loading = () => {
  return (
    <Box
    sx={{
      position: "fixed",
      top: "50%",
      left: "50%",
      width: "100px",
      height: "100px",
      transform: "translate(-50%, -50%)",
      display: "flex",
      zIndex: 1000,
      justifyContent: "center",
      alignItems: "center",
    }}
  >
    <CircularProgress color="secondary" size='5rem' />
  </Box>
  )
}