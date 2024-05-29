# Shall We Move: Multiplayer Blackjack on Sui Blockchain

Welcome to Shall We Move, a fully on-chain multiplayer Blackjack game implemented on the Sui blockchain. This project leverages the unique features of the Sui blockchain to provide secure, transparent, and decentralized gameplay.

![Shall We Move Landing Page](images/landing.jpg)

Dive into the game interface, designed to offer a seamless and engaging Blackjack experience with real-time multiplayer support.

![Shall We Move Game Page](images/game.jpg)



# Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Get Started](#get-started)

# Overview

Shall We Move is a decentralized application (dApp) that brings the classic game of Blackjack to the Sui blockchain. All game functionalities, including card dealing, shuffling, and hiding are executed on-chain using encryption and randomness to ensure fairness and transparency.

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

- Node.js (v18.x or later)
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
sui move create-casino
sui move create-lounge
```

## Frontend

### Set Environment Variables
- package address
- casino address
- lounge address

`cd frontend` and create a `.env.local` file with the following content:
```
PACKAGE_ADDRESS=0x1234567890
CASINO_ADDRESS=0x1234567890
LOUNGE_ADDRESS=0x1234567890
```

### Install Dependencies
```bash
pnpm install
```

### Start the Development Server
```bash
pnpm dev
```
