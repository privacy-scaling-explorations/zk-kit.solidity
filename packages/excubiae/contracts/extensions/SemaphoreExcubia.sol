// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Excubia} from "../Excubia.sol";
import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";

/// @title Semaphore Excubia Contract
/// @notice This contract extends the Excubia contract to integrate with the Semaphore protocol.
/// It verifies the passerby Semaphore group membership proofs to grant access through the gate.
/// @dev To allow only specific Semaphore identities from a group, the contract stores the specific group identifier.
/// To avoid identities from passing twice, nullifiers are stored upon successful verification of the proofs.
contract SemaphoreExcubia is Excubia {
    /// @notice The Semaphore contract interface.
    ISemaphore public immutable SEMAPHORE;
    /// @notice The specific group identifier that proofs must match to pass the gate.
    /// @dev Used as a `scope` to ensure consistency during proof membership verification.
    uint256 public immutable GROUP_ID;

    /// @notice Mapping to track which nullifiers have been used to avoid passing the
    /// gate twice using the same Semaphore identity.
    /// @dev The nullifier is derived from the hash of the secret and group identifier,
    /// ensuring that the same identity cannot be registered twice for the same group.
    mapping(uint256 => bool) public passedNullifiers;

    /// @notice Error thrown when the group identifier does not match the expected one.
    error InvalidGroup();

    /// @notice Error thrown when the proof is invalid.
    error InvalidProof();

    /// @notice Error thrown when the proof scope does not match the expected group identifier.
    error UnexpectedScope();

    /// @notice Constructor to initialize with target Semaphore contract and specific group identifier.
    /// @param _semaphore The address of the Semaphore contract.
    /// @param _groupId The group identifier that proofs must match.
    constructor(address _semaphore, uint256 _groupId) {
        if (_semaphore == address(0)) revert ZeroAddress();

        SEMAPHORE = ISemaphore(_semaphore);

        if (SEMAPHORE.groupCounter() < _groupId) revert InvalidGroup();

        GROUP_ID = _groupId;
    }

    /// @notice Internal function to handle the passing logic with check.
    /// @dev Calls the parent `_pass` function and registers the nullifier to avoid passing the gate twice.
    /// @param passerby The address of the entity attempting to pass the gate.
    /// @param data Additional data required for the check (ie., encoded Semaphore proof).
    function _pass(address passerby, bytes calldata data) internal override {
        ISemaphore.SemaphoreProof memory proof = abi.decode(data, (ISemaphore.SemaphoreProof));

        // Avoiding passing the gate twice using the same nullifier.
        if (passedNullifiers[proof.nullifier]) revert AlreadyPassed();

        super._pass(passerby, data);

        passedNullifiers[proof.nullifier] = true;
    }

    /// @notice Internal function to handle the gate protection (proof check) logic.
    /// @dev Checks if the proof matches the group ID, scope, and is valid.
    /// @param passerby The address of the entity attempting to pass the gate.
    /// @param data Additional data required for the check (i.e., encoded Semaphore proof).
    /// @return True if the proof is valid and the passerby passes the check, false otherwise.
    function _check(address passerby, bytes calldata data) internal view override returns (bool) {
        super._check(passerby, data);

        ISemaphore.SemaphoreProof memory proof = abi.decode(data, (ISemaphore.SemaphoreProof));

        if (GROUP_ID != proof.scope) revert UnexpectedScope();

        if (!SEMAPHORE.verifyProof(GROUP_ID, proof)) revert InvalidProof();

        return true;
    }
}
