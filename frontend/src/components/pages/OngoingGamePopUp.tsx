import {Box, Button, styled, Typography} from "@mui/material";
import React from "react";
import { useRouter } from "next/router";
import {LOCAL_STORAGE_ONGOING_GAME_KEY} from "@/api/game";

interface OngoingGamePopUpProps {
    onClose: () => void;
}

const OngoingGamePopUp = ({ onClose }: OngoingGamePopUpProps) => {
    const router = useRouter();

    const handleResumeGame = () => {
        const ongoingGameId = localStorage.getItem(LOCAL_STORAGE_ONGOING_GAME_KEY);
        router.push(`/game/${ongoingGameId}`);
    }

    const handleIgnoreWarning = () => {
        localStorage.removeItem(LOCAL_STORAGE_ONGOING_GAME_KEY);
        onClose();
    }

    return (
        <PopUpOverlay>
            <PopUpContainer>
                <Typography
                    variant="h2"
                    sx={{
                        fontWeight: 'bold',
                        marginBottom: '5px',
                    }}
                >
                    Game in progress
                </Typography>
                <Box
                    sx={{
                        width: '100%',
                        borderBottom: '1px solid #000',
                        marginBottom: '20px',
                    }}
                />
                <Typography
                    variant="h4"
                    paragraph
                    sx={{
                        marginBottom: '40px',
                    }}
                >
                    There is a game in progress. <br />
                    If you want <strong>to start a new game, you must exit the current game.</strong>
                </Typography>


                <Box
                    sx={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        gap: '20px',
                    }}
                >
                    <Button
                        color="secondary"
                        onClick={handleIgnoreWarning}
                        sx={{
                            padding: "16px 20px",
                            fontSize: "0.7rem",
                            color: "white",
                            fontWeight: 700,
                            borderRadius: "40px",
                            backgroundColor: "#FC4100",
                        }}
                    >
                        (DANGER) Ignore this warning
                    </Button>

                    <Button
                        color="secondary"
                        size="large"
                        variant="contained"
                        onClick={handleResumeGame}
                        sx={{
                            padding: "16px 20px",
                            fontSize: "0.7rem",
                            color: "white",
                            fontWeight: 700,
                            borderRadius: "40px",
                        }}
                    >
                        Resume Game
                    </Button>
                </Box>
            </PopUpContainer>
        </PopUpOverlay>
    )
}

const PopUpOverlay = styled(Box)({
    position: 'fixed',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
});

const PopUpContainer = styled(Box)({
    color: '#000',
    padding: '60px 120px',
    borderRadius: '8px',
    width: '80%',
    maxWidth: '800px',
    position: 'relative',
    gap: 40,
    backdropFilter: "blur(7px)",
    backgroundColor: "rgba(255, 255, 255, 0.5)",
    border: "1px solid rgba(255, 255, 255, 0.7)",
});

export default OngoingGamePopUp;