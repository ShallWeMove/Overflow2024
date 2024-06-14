export enum GameType {
    TwoCardsPoker = 0,
    ThreeCardsPoker = 1,
}

export interface GameConfig {
    packageId: string;
    objects: {
        casinoId: string;
        loungeId: string;
    }
}

export interface Config {
    core: {
        packageId: string;
    };

    games: {
        twoCardsPoker: GameConfig,
        threeCardsPoker: GameConfig,
    };
}

const config: Config = {
    core: {
        packageId: '0xbb82f18ff31baf24223bac5176f2c272fdf296cfef5ef32b255af200f161b3ea',
    },

    games: {
        twoCardsPoker: {
            packageId: '0x9149494986fdf96ca98971313da3329dcd3a3396238bc7cf0a372e8f5747027a',
            objects: {
                casinoId: '0x5b9d2b62c3a0a79341e24844e71947c5366ea3d078658485d39685e04745e1c2',
                loungeId: '0xe88cc89eaee3d13315572b1b0679f58dbc031305776f32ffd84c33d9a5aba1d3',
            }
        },
        threeCardsPoker: {
            packageId: '0x2cddba646146b7e3964eed9b9905d15027555f583addd1e6bef4a86c275485c8',
            objects: {
                casinoId: '0x5b9d2b62c3a0a79341e24844e71947c5366ea3d078658485d39685e04745e1c2',
                loungeId: '0x9344be522ec8dca0fad97735d9b7a27567482a95f69990745075193421fa493b',
            }
        },
    },
};

export default config;
