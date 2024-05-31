# Entirely Blockchain-Powered Multiplayer Card Game:  _Play, Create, Share_

Welcome to **Shall We Move**, a fully on-chain multiplayer card game implemented on the Sui blockchain. This project leverages the unique features of the Sui blockchain to provide secure, transparent, and decentralized gameplay.

![Shall We Move Landing Page](images/landing.png)

Immerse yourself in the game interface, crafted to provide a smooth and captivating card gaming experience with real-time multiplayer support.

![Shall We Move Game Page](images/game.png)

# Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Get Started](#get-started)
- [Game Rules](#game-rules)

# Overview

**Shall We Move** is a decentralized application (dApp) that brings the classic game of 2-card poker to the Sui blockchain. All game functionalities, including card dealing, shuffling, and hiding are executed on-chain using encryption and randomness to ensure fairness and transparency.

# Features

- **Multiplayer Support**: Play Blackjack with multiple players in real-time.
- **On-Chain Execution**: All game logic runs on the Sui blockchain, ensuring transparency and security.
- **Encryption**: Cards are encrypted to keep them hidden from other players.
- **Randomness**: Cards are dealt randomly to ensure fair play.
- **Next.js + Typescript Frontend**: A modern, responsive web interface for seamless gameplay.

# Tech Stack

- **Frontend**: Next.js, Typescript
- **Blockchain**: Sui
- **Smart Contracts**: Move language

# Get Started

To run the project locally, follow these steps:

## Prerequisites

- Node.js (v18.17.0 or later)
- pnpm
- Sui Blockchain node (or access to a Sui node)

## Clone the Repository

```bash
git clone https://github.com/ShallWeMove/Overflow2024.git
```

## Smart Contracts

### Publish the Smart Contracts

you should see the package address in the output after running the command below.

```bash
cd shallwemove
sui client publish
```

### Create your Casino & Lounge on the Sui Blockchain

you should see the casino and lounge addresses in the output after running the command above. Use these addresses to create your casino and lounge on the Sui blockchain.

```bash
### create-casino
sui client call --package {package_address} --module cardgame --function create_casino --args {n_value_of_public_key} --gas-budget 1000000000
ex) sui client call --package 0x9624ccf91b6c191a231e3538e9e6b533b7467aade40d16c7277119e2ea19240b --module cardgame --function create_casino --args 35263 --gas-budget 1000000000

### create lounge
sui client call --package {package_address} --module cardgame --function create_lounge --args {casino_id} {max_round} --gas-budget 1000000000
ex) sui client call --package 0x9624ccf91b6c191a231e3538e9e6b533b7467aade40d16c7277119e2ea19240b --module cardgame --function create_lounge --args 0xfd404dd0b9af26e67a0b6e7265845fdea494973d2e31a583f41e48ed5f6b4dec 1 --gas-budget 1000000000

### add game table to lounge
sui client call --package {package_address} --module cardgame --function add_game_table --args {casino_id} {lounge_id} {ante_amount} {bet_unit} {game_seats} 0x0000000000000000000000000000000000000000000000000000000000000008 --gas-budget 1000000000
ex) sui client call --package 0x9624ccf91b6c191a231e3538e9e6b533b7467aade40d16c7277119e2ea19240b --module cardgame --function add_game_table --args 0xfd404dd0b9af26e67a0b6e7265845fdea494973d2e31a583f41e48ed5f6b4dec 0x61fb61bb778d7554ff6490975470b6b10b3821ccc82092c430fcf7d939a37881 500 500 5 0x0000000000000000000000000000000000000000000000000000000000000008 --gas-budget 1000000000

sui move create-lounge
```

## Frontend

### Set Environment Variables

- package address
- casino address
- lounge address

`cd frontend` and update the top line of `src/api/game.ts` file with the following content:
```
const PACKAGE_ID = "{YOUR PACKAGE ID}";
const CASINO_ID = "{YOUR CASINO ID}";
const LOUNGE_ID = "{YOUR LOUNGE ID}";
```

### Install Dependencies

```bash
pnpm install
```

### Start the Development Server

```bash
pnpm dev
```

# Game Rules

## Overview of Rules
In contrast to traditional poker, which utilizes 5 cards, Mini Poker is played with only 2 cards, forming combinations to create hands (poker hands). Following the 2-card rule, players are dealt one card each, engage in betting, then receive the second card and proceed with another round of betting before revealing their hands to determine the winner. The draw rule is applied, ensuring that players' cards remain undisclosed throughout the game.

## Betting Rules

- **Ante**: The mandatory initial bet placed at the beginning of the game to ensure active participation and discourage excessive folding without betting. It serves to encourage more proactive betting behavior.

- **Check**: A privilege given to the player who either must bet the minimum amount or is the first player to bet regardless of their hand. It allows them to pass their turn without adding more money to the pot.

- **Bet**: The act of placing the first bet after card exchange or additional distribution. If no one bets, the round progresses with everyone checking, without further betting.

- **Call**: Accepting the amount of money bet by the previous player.

- **Raise**: Accepting the previous bet and adding more to it.

- **Fold**: Surrendering the hand, resulting in the loss of any money bet before folding. Folding is employed to minimize further losses when a player assesses that their hand has little chance of winning.

## Poker Hands

### Straight Flush Series

- **Royal Straight Flush**: A combination of A and K cards of the same suit. It is the strongest hand.

- **Back Straight Flush**: A combination of A and 2 cards of the same suit. Depending on the rules, it may be recognized as the second strongest hand.

- **Straight Flush**: A combination of two consecutive numbers of the same suit. It is the third strongest hand.

### Pair

- A pair consists of two cards with the same number or the same letter, such as J, Q, K.
