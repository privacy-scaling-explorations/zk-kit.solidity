// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Excubia} from "../Excubia.sol";
import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

/// @title EAS Excubia Contract.
/// @notice This contract extends the Excubia contract to integrate with the Ethereum Attestation Service (EAS).
/// This contract checks an EAS attestation to permit access through the gate.
/// @dev The contract uses a specific attestation schema & attester to admit the recipient of the attestation.
contract EASExcubia is Excubia {
    /// @notice The Ethereum Attestation Service contract interface.
    IEAS public immutable EAS;
    /// @notice The specific schema ID that attestations must match to pass the gate.
    bytes32 public immutable SCHEMA;
    /// @notice The trusted attester address whose attestations are considered
    /// the only ones valid to pass the gate.
    address public immutable ATTESTER;

    /// @notice Mapping to track which attestations have been registered by the contract to
    /// avoid double checks with the same attestation.
    mapping(bytes32 => bool) public registeredAttestations;

    /// @notice Error thrown when the attestation has been already used to pass the gate.
    error AlreadyRegistered();

    /// @notice Error thrown when the attestation does not match the designed schema.
    error UnexpectedSchema();

    /// @notice Error thrown when the attestation does not match the designed trusted attester.
    error UnexpectedAttester();

    /// @notice Error thrown when the attestation does not match the passerby as recipient.
    error UnexpectedRecipient();

    /// @notice Error thrown when the attestation has been revoked.
    error RevokedAttestation();

    /// @notice Constructor to initialize with target EAS contract with specific attester and schema.
    /// @param _eas The address of the EAS contract.
    /// @param _attester The address of the trusted attester.
    /// @param _schema The schema ID that attestations must match.
    constructor(address _eas, address _attester, bytes32 _schema) {
        if (_eas == address(0) || _attester == address(0)) revert ZeroAddress();

        EAS = IEAS(_eas);
        ATTESTER = _attester;
        SCHEMA = _schema;
    }

    /// @notice Overrides the `_pass` function to register a correct attestation.
    /// @param passerby The address of the entity attempting to pass the gate.
    /// @param data Encoded attestation ID.
    function _pass(address passerby, bytes calldata data) internal override {
        bytes32 attestationId = abi.decode(data, (bytes32));

        // Avoiding double check of the same attestation.
        if (registeredAttestations[attestationId]) revert AlreadyRegistered();

        registeredAttestations[attestationId] = true;

        super._pass(passerby, data);
    }

    /// @notice Overrides the `_check` function to validate the attestation against specific criteria.
    /// @param passerby The address of the entity attempting to pass the gate.
    /// @param data Encoded attestation ID.
    /// @return True if the attestation meets all criteria, revert otherwise.
    function _check(address passerby, bytes calldata data) internal view override returns (bool) {
        Attestation memory attestation = EAS.getAttestation(abi.decode(data, (bytes32)));

        if (attestation.schema != SCHEMA) revert UnexpectedSchema();
        if (attestation.attester != ATTESTER) revert UnexpectedAttester();
        if (attestation.recipient != passerby) revert UnexpectedRecipient();
        if (attestation.revocationTime != 0) revert RevokedAttestation();

        return true;
    }
}
