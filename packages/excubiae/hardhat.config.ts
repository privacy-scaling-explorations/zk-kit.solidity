import "@nomicfoundation/hardhat-toolbox"
import { HardhatUserConfig } from "hardhat/config"

const hardhatConfig: HardhatUserConfig = {
    solidity: {
        version: "0.8.20",
        settings: {
            optimizer: {
                enabled: true
            }
        }
    },
    gasReporter: {
        currency: "USD",
        enabled: process.env.REPORT_GAS === "true"
    },
    typechain: {
        target: "ethers-v6"
    }
}

export default hardhatConfig
