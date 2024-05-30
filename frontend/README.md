# Shall We Move Frontend

This is the frontend part of the Shall We Move project, a fully on-chain multiplayer Blackjack game implemented on the Sui blockchain. The frontend is built using Next.js and Typescript, and managed with pnpm.

## Overview

This frontend application serves as the user interface for Shall We Move. It allows players to interact with the game, join tables, and play Blackjack in a decentralized and secure manner.

## Tech Stack

- **Framework**: [Next.js](https://nextjs.org/)
- **Language**: [Typescript](https://www.typescriptlang.org/)
- **Package Manager**: [pnpm](https://pnpm.io/)

## Installation

To set up the project locally, follow these steps:

### Prerequisites

- Node.js (v18.x or later)
- pnpm

### Set Environment Variables
- package address
- casino address
- lounge address

create a `.env.local` file with the following content:
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

