// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IExcubia} from "./IExcubia.sol";

/// @title Excubia.
/// @notice Abstract base contract which can be extended to implement a specific excubia.
/// @dev Inherit from this contract and implement the `_check` and/or `_pass()` methods
/// to define the custom gatekeeping logic.
abstract contract Excubia is IExcubia, Ownable(msg.sender) {
    /// @notice The excubia-protected contract address.
    /// @dev The gate can be any contract address that requires a prior `_check`.
    /// For example, the gate is a Semaphore group that requires the passerby
    /// to meet certain criteria before joining.
    address public gate;

    /// @dev Modifier to restrict function calls to only from the gate address.
    modifier onlyGate() {
        if (msg.sender == gate) revert GateOnly();
        _;
    }

    /// @inheritdoc IExcubia
    function setGate(address _gate) public virtual onlyOwner {
        if (gate != address(0)) revert GateAlreadySet();

        _setGate(_gate);
    }

    /// @dev Internal method to directly set the gate address.
    /// @param _gate The address of the contract to be set as the gate.
    function _setGate(address _gate) internal virtual {
        gate = _gate;
    }

    /// @inheritdoc IExcubia
    function pass(address passerby, bytes calldata data) public virtual onlyGate {
        _pass(passerby, data);
    }

    /// @dev Internal method that performs the check and emits an event if the check is passed.
    /// Can throw errors the {AccessDenied} error if the `_check` method returns false.
    /// @param passerby The address of the entity attempting to pass the gate.
    /// @param data Additional data required for the check.
    function _pass(address passerby, bytes calldata data) internal virtual {
        if (!_check(passerby, data)) revert AccessDenied();

        emit GatePassed(passerby, gate);
    }

    /// @dev Abstract internal function to be implemented with custom logic to check if the passerby can pass the gate.
    /// @param passerby The address of the entity attempting to pass the gate.
    /// @param data Additional data that may be required for the check.
    /// @return True if the passerby passes the check, false otherwise.
    function _check(address passerby, bytes calldata data) internal virtual returns (bool);
}
