// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title IExcubia
/// @notice Interface for the excubia contract.
interface IExcubia {
    /// @notice Event emitted when someone passes the `_check` method.
    /// @param passerby The address of those who have successfully passed the check.
    /// @param gate The address of the excubia-protected contract address.
    event GatePassed(address indexed passerby, address indexed gate);

    /// @notice Sets the gate address.
    /// @param _gate The address of the contract to be set as the gate.
    function setGate(address _gate) external;

    /// @notice Initiates the excubia's check and triggers the associated action if the check is passed.
    /// @param data Additional data required for the check.
    function open(bytes calldata data) external;
}
