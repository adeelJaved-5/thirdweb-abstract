// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC1155} from "./Utils.sol";
import {Ownable} from "./Utils.sol";
import {MerkleProof} from "./Utils.sol";

contract TNFT is ERC1155, Ownable {
    uint256 public mintPrice = 0.001 ether; // Mint price in ETH
    uint256 public constant MAX_SUPPLY = 5000; // Max supply of tokens
    uint256 public nextTokenId = 1; // Start minting from token ID 1

    // Whitelist
    bytes32 public merkleRoot; // Merkle root for whitelist
    mapping(address => bool) public hasMinted; // Tracks if an address has minted

    // Minting window
    uint256 public startTime; // Start timestamp for minting
    uint256 public endTime; // End timestamp for minting

    constructor() ERC1155("TNFT", "TNFT", "https://api.ipfs.metadata/") {}

    // Mint function (whitelist only)
    function mint(bytes32[] calldata merkleProof) external payable {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Minting not active");
        require(msg.value == mintPrice, "Incorrect ETH sent");
        require(!hasMinted[msg.sender], "Already minted");
        require(nextTokenId <= MAX_SUPPLY, "Exceeds max supply");

        // Verify Merkle proof
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, merkleRoot, leaf), "Not whitelisted");

        // Mint NFT
        _mint(msg.sender, nextTokenId, 1, "");
        nextTokenId++;
        hasMinted[msg.sender] = true;
    }

    // Set Merkle root (only owner)
    function setMerkleRoot(bytes32 newMerkleRoot) external onlyOwner {
        merkleRoot = newMerkleRoot;
    }

    // Set minting window (only owner)
    function setMintingWindow(uint256 newStartTime, uint256 newEndTime) external onlyOwner {
        require(newStartTime < newEndTime, "Invalid time range");
        startTime = newStartTime;
        endTime = newEndTime;
    }

    // Change mint price (only owner)
    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    // Change base URI (only owner)
    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    // Withdraw collected ETH (only owner)
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}