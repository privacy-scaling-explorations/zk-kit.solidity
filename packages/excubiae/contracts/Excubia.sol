// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Excubia.
/// @notice Abstract base contract which can be extended to implement a specific excubia.
/// @dev Inherit from this contract and implement the `_check` method to define the custom gatekeeping logic.
abstract contract Excubia is Ownable(msg.sender) {
    /// @notice The excubia-protected contract address.
    /// @dev The gate can be any contract address that requires a prior `_check`.
    /// For example, the gate is a semaphore group that requires the passerby
    /// to meet certain criteria before joining.
    address public gate;

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
    function setGate(address _gate) public virtual onlyOwner {
        if (gate != address(0)) revert GateAlreadySet();

        _setGate(_gate);
    }

    /// @dev Internal method to directly set the gate address.
    /// @param _gate The address of the contract to be set as the gate.
    function _setGate(address _gate) internal virtual {
        gate = _gate;
    }

    /// @notice Initiates the excubia's check and triggers the associated action if the check is passed.
    /// @dev Calls `_pass` to handle the logic of checking and passing the gate.
    /// @param data Additional data required for the check (e.g., encoded token identifier).
    function pass(bytes memory data) public virtual {
        _pass(data);
    }

    /// @dev Internal method that performs the check and emits an event if the check is passed.
    /// Can throw errors as {GateNotSet} if the gate address has not been set or.
    /// {AccessDenied} if the `_check` method returns false.
    /// @param data Additional data required for the check.
    function _pass(bytes memory data) internal virtual {
        if (gate == address(0)) revert GateNotSet();
        if (!_check(msg.sender, data)) revert AccessDenied();

        emit GatePassed(msg.sender, gate);
    }

    /// @dev Abstract internal function to be implemented with custom logic to check if the passerby can pass the gate.
    /// @param passerby The address of the entity attempting to pass the gate.
    /// @param data Additional data that may be required for the check.
    /// @return True if the passerby passes the check, false otherwise.
    function _check(address passerby, bytes memory data) internal virtual returns (bool);
}
