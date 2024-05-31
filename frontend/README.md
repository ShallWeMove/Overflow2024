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

update the top line of `src/api/game.ts` file with the following content:
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

