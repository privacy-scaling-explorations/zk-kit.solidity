// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title IExcubia.
/// @notice Excubia contract interface.
interface IExcubia {
    /// @notice Event emitted when someone passes the `_check` method.
    /// @param passerby The address of those who have successfully passed the check.
    /// @param gate The address of the excubia-protected contract address.
    event GatePassed(address indexed passerby, address indexed gate);

    /// @notice Error thrown when the gate address is not set.
    error GateNotSet();

    /// @notice Error thrown when the gate address has been already set.
    error GateAlreadySet();

    /// @notice Error thrown when access is denied by the excubia.
    error AccessDenied();

    /// @notice Sets the gate address.
    /// @dev Only the owner can set the destination gate address.
    /// @param _gate The address of the contract to be set as the gate.
    function setGate(address _gate) external;

    /// @notice Initiates the excubia's check and triggers the associated action if the check is passed.
    /// @dev Calls `_pass` to handle the logic of checking and passing the gate.
    /// @param data Additional data required for the check (e.g., encoded token identifier).
    /// @param passerby The address of the entity attempting to pass the gate.
    function pass(bytes memory data, address passerby) external;
}
