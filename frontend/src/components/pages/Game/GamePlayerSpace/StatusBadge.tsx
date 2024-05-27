import { Box, Button, Typography, styled } from "@mui/material";

export const StatusBadge = ({value} : any) => {
  return(
		<Container color={"white"}>
      <AmountWrapper>
        <Amount>
          <Typography color="white" fontWeight={700}>
            {value}
          </Typography>
        </Amount>
      </AmountWrapper>
    </Container>
  )
}
const Container = styled(Box)<{ color: string }>(({ color }) => ({
	position: "relative",
	// border: `2px solid ${color}`,
	borderRadius: 4,
	backgroundColor: "transparent",
	flexGrow: 1,
	fontSize: 24,
	fontWeight: "bold",
	textAlign: "center",
}));


const AmountWrapper = styled(Box)({
	width: "100%",
	// position: "absolute",
	bottom: 30,
	display: "flex",
	justifyContent: "center",
});

const Amount = styled(Box)({
	backgroundColor: "black",
	padding: "2px 12px",
	borderRadius: "15px",
});
