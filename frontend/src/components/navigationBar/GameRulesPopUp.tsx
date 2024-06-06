// components/GameRulesPopup.tsx
import React, { useState } from 'react';
import {Box, Button, styled, Typography} from "@mui/material";

interface GameRulesPopupProps {
    onClose: () => void;
    showRules: boolean;
}

const GameRulesPopup = ({ onClose, showRules }: GameRulesPopupProps) => {
    const [currentStep, setCurrentStep] = useState(0);

    interface Rule {
        title: string;
        content: string[];
    }

    const rules: Rule[] = [
        {
            title: "Wallet Setup",
            content: [
                "Connect your Sui wallet.",
                "In the wallet settings, set the Network to Testnet, as only Testnet is supported.",
                "If you don't have any Testnet Sui Tokens, click the \"Request Testnet Sui Tokens\" button."
            ],
        },
        {
            title:"Starting the Game",
            content: [
                "To join the game, click the \"Enter Game\" button on the homepage.",
                "Press the \"Ante\" button to indicate your intention to participate.",
                "The game requires at least 2 players to start and can accommodate up to 5 players.",
                "Once 2 or more players have joined and pressed the \"Ante\" button, the Manager can click the \"Start Game\" button to begin.",
            ],
        },
        {
            title: "Betting Rules",
            content: [
                "\"Ante\"",
                "The mandatory initial bet placed at the beginning of the game to ensure active participation and discourage excessive folding without betting. It serves to encourage more proactive betting behavior.",
                "\"Check\"",
                "A privilege given to the player who either must bet the minimum amount or is the first player to bet regardless of their hand. It allows them to pass their turn without adding more money to the pot.",
                "\"Bet\"",
                "The act of placing the first bet after card exchange or additional distribution. If no one bets, the round progresses with everyone checking, without further betting.",
                "\"Call\"",
                "Accepting the amount of money bet by the previous player.",
                "\"Raise\"",
                "Accepting the previous bet and adding more to it.",
                "\"Fold\"",
                "Surrendering the hand, resulting in the loss of any money bet before folding. Folding is employed to minimize further losses when a player assesses that their hand has little chance of winning.",
            ]
        },
        {
            title: "Hand Rankings",
            content: [
                "\"Straight Flush Series\"",
                "Royal Straight Flush: A combination of A and K cards of the same suit. It is the strongest hand.",
                "Back Straight Flush: A combination of A and 2 cards of the same suit. Depending on the rules, it may be recognized as the second strongest hand.",
                "Straight Flush: A combination of two consecutive numbers of the same suit. It is the third strongest hand.",
                "\"Pair\"",
                "A pair consists of two cards with the same number or the same letter, such as J, Q, K",
                "\"Straight Series\"",
                "Royal Straight (Mountain): A combination of A and K cards with different suits. It is one of the strongest combinations among straight hands.",
                "Back Straight: It consists of A and 2 cards with different suits.",
                "Straight: A combination of two consecutive numbers with different suits. In mini poker, similar to three of a kind, this hand is considered higher than a flush.",
                "\"Flush\"",
                "A flush consists of two cards of the same suit.",
                "\"Top\"",
                "The highest single card in a hand, not forming any particular combination. It does not contribute to any specific hand rank. An Ace (A) is the highest top card, and a 4 is the lowest.",
            ],
        }
    ];

    const parseContent = (text: string) => {
        const parts = text.split(/(\"[^\"]+\")/g);
        return parts.map((part, index) => {
            if (part.startsWith('"') && part.endsWith('"')) {
                return <strong key={index}>{part.slice(1, -1)}</strong>;
            }
            return part;
        });
    };

    const handleNext = () => {
        if (currentStep < rules.length - 1) {
            setCurrentStep(prevStep => prevStep + 1);
        }
    };

    const handlePrev = () => {
        if (currentStep > 0) {
            setCurrentStep(prevStep => prevStep - 1);
        }
    };

    return showRules && (
        <PopUpOverlay onClick={onClose}>
            <PopUpContainer onClick={(e) => e.stopPropagation()}>
                <CloseButton onClick={onClose}>X</CloseButton>
                <Box>
                    <Typography
                        variant="h3"
                        sx={{
                            fontWeight: 'bold',
                            marginBottom: '10px',
                        }}
                    >
                        Poker Game Rules
                        <Typography
                            variant="h5"
                            sx={{
                                fontWeight: 'bold',
                                color: 'grey',
                            }}
                        >
                            Step {currentStep + 1}: {rules[currentStep].title}
                        </Typography>
                    </Typography>
                    <Box
                        sx={{
                            width: '100%',
                            borderBottom: '1px solid #000',
                            marginBottom: '20px',
                        }}
                    />
                    <Typography
                        variant="body1"
                        paragraph
                        sx={{ marginBottom: '20px' }}
                    >
                        {rules[currentStep].content.map((line, index) => (
                            <Typography
                                key={index}
                                sx={{ marginBottom: '5px' }}
                            >
                                {parseContent(line)}
                            </Typography>
                        ))}
                    </Typography>
                    <Box>
                        <Button color="success" onClick={handlePrev} disabled={currentStep === 0}>Previous</Button>
                        <Button color="info" onClick={handleNext} disabled={currentStep === rules.length - 1}>Next</Button>
                    </Box>
                </Box>
            </PopUpContainer>
        </PopUpOverlay>
    );
};

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
    backgroundColor: '#fff',
    padding: '60px 120px',
    borderRadius: '8px',
    width: '80%',
    maxWidth: '800px',
    position: 'relative',
});

const CloseButton = styled(Button)({
    position: 'absolute',
    top: '10px',
    right: '10px',
    border: 'none',
    background: 'none',
    fontSize: '20px',
    cursor: 'pointer',
});
export default GameRulesPopup;
