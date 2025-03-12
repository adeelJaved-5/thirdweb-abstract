require("@matterlabs/hardhat-zksync-solc");
require("@matterlabs/hardhat-zksync-verify");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  zksolc: {
    version: "1.4.1",
    compilerSource: "binary",
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  networks: {
    asbtract: {
      url: "https://11124.rpc.thirdweb.com/53b0c4a5b71544cdcc8b0867a442ab2b",
      ethNetwork: "sepolia",
      zksync: true,
      chainId: 11124,
      verifyURL:
        "https://explorer.testnet.abs.xyz/contract_verification",
    }
  },
  paths: {
    artifacts: "./artifacts-zk",
    cache: "./cache-zk",
    sources: "./contracts",
    tests: "./test",
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
