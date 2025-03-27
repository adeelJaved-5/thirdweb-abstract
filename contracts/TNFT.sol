// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC1155} from "./Utils.sol";
import {Ownable} from "./Utils.sol";
import {MerkleProof} from "./Utils.sol";

contract TNFT is ERC1155, Ownable {
    uint256 public constant MAX_SUPPLY = 5000;
    uint256 public nextTokenId = 1;
    uint256 private lock = 1;

    struct Phase {
        bytes32 merkleRoot;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(uint8 => Phase) public phases;
    mapping(address => bool) public hasMinted;

    constructor() ERC1155("TNFT", "TNFT", "https://api.ipfs.metadata/") {}

    event Minted(address indexed minter, uint256 tokenId, uint8 phaseId);
    event PhaseUpdated(
        uint8 phaseId,
        uint256 price,
        uint256 startTime,
        uint256 endTime
    );
    event URIUpdated(string newURI);

    modifier nonReentrant() {
        require(lock == 1, "ReentrancyGuard: reentrant call");
        lock = 2;
        _;
        lock = 1;
    }

    function setPhase(
        uint8 phaseId,
        bytes32 merkleRoot,
        uint256 price,
        uint256 startTime,
        uint256 endTime
    ) external onlyOwner {
        require(startTime < endTime, "Invalid time range");
        phases[phaseId] = Phase(merkleRoot, price, startTime, endTime);
        emit PhaseUpdated(phaseId, price, startTime, endTime);
    }

    function setURI(string memory newURI) external onlyOwner {
        _setURI(newURI);
        emit URIUpdated(newURI);
    }

    function mintIconics(
        bytes32[] calldata merkleProof
    ) external payable nonReentrant {
        _mintForPhase(1, merkleProof);
    }

    function mintNoobs(
        bytes32[] calldata merkleProof
    ) external payable nonReentrant {
        _mintForPhase(2, merkleProof);
    }

    function mintNFTHolders(
        bytes32[] calldata merkleProof
    ) external payable nonReentrant {
        _mintForPhase(3, merkleProof);
    }

    function mintBithubUsers(
        bytes32[] calldata merkleProof
    ) external payable nonReentrant {
        _mintForPhase(4, merkleProof);
    }

    function _mintForPhase(
        uint8 phaseId,
        bytes32[] calldata merkleProof
    ) internal {
        require(
            block.timestamp >= phases[phaseId].startTime &&
                block.timestamp <= phases[phaseId].endTime,
            "Minting not active"
        );
        require(msg.value == phases[phaseId].price, "Incorrect ETH sent");
        require(!hasMinted[msg.sender], "Already minted");
        require(nextTokenId <= MAX_SUPPLY, "Exceeds max supply");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verifyCalldata(
                merkleProof,
                phases[phaseId].merkleRoot,
                leaf
            ),
            "Not whitelisted"
        );

        _mint(msg.sender, nextTokenId, 1, "");
        hasMinted[msg.sender] = true;
        emit Minted(msg.sender, nextTokenId, phaseId);
        nextTokenId++;
    }

    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = owner().call{value: address(this).balance}("");
        +require(success, "Transfer failed.");
    }
}
