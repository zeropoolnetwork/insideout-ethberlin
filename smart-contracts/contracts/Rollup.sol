// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import { UltraVerifier } from "./UltraVerifier.sol";    



contract Rollup {
    uint256 constant GENESIS_ROOT_STATE = 0; // TODO: Define it
    uint256 constant RANDOM_ORACLE_SIZE = 10;

    // BN256 group order
    uint256 constant R = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    uint256 constant BLOCKNUMBER_MAX_DELAY = 10;

    UltraVerifier public verifier;
    address public owner;
    uint256 public last_committed_blocknumber = 0;

    uint256 public root = GENESIS_ROOT_STATE;

    error NotAuthorized();
    error WrongBlockNumber();
    error WrongProof();

    constructor(address _owner) {
        verifier = new UltraVerifier();
        owner = _owner;
    }

    function publish_block(uint256 new_root, uint256 _now, bytes calldata _proof) external {
        if (msg.sender != owner) {
            revert NotAuthorized();
        }

        if (_now <= last_committed_blocknumber) {
            revert WrongBlockNumber();
        }

        if (_now <= block.number - BLOCKNUMBER_MAX_DELAY) {
            revert WrongBlockNumber();
        }

        if (_now >= block.number) {
            revert WrongBlockNumber();
        }

        // use block hashes as random oracle, should be replaced to randao
        uint256[RANDOM_ORACLE_SIZE] memory oracle;
        for (uint256 i = _now-RANDOM_ORACLE_SIZE+1; i <= _now; i++) {
            oracle[i] = uint256(blockhash(i));
        }

        uint256 h = uint256(keccak256(abi.encodePacked(root, new_root, _now, _now-RANDOM_ORACLE_SIZE+1, oracle)))%R;

        bytes32[] memory inputs = new bytes32[](1);
        inputs[0] = bytes32(h);

        if (!verifier.verify(_proof, inputs)) {
            revert WrongProof();
        }

        last_committed_blocknumber = _now;
        root = new_root;
    }
}
