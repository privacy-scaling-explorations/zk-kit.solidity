// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Excubia} from "../Excubia.sol";

/// @title FreeForAll Excubia Contract.
/// @notice This contract extends the Excubia contract to allow free access through the gate.
/// This contract does not perform any checks and allows any passerby to pass the gate.
/// @dev The contract overrides the `_check` function to always return true.
contract FreeForAllExcubia is Excubia {
    /// @notice Constructor for the FreeForAllExcubia contract.
    constructor() {}

    /// @notice Mapping to track already registered passersby.
    mapping(bytes32 => bool) public registeredPassersby;

    /// @notice Internal function to handle the gate passing logic.
    /// @dev This function calls the parent `_pass` function and then tracks the passerby.
    /// @param passerby The address of the entity passing the gate.
    /// @param data Additional data required for the pass (not used in this implementation).
    function _pass(address passerby, bytes calldata data) internal override {
        super._pass(passerby, data);

        bytes32 encodedPasserby = keccak256(abi.encodePacked(passerby));

        // Avoiding double check of the same passerby.
        if (registeredPassersby[encodedPasserby]) revert AlreadyRegistered();

        registeredPassersby[encodedPasserby] = true;
    }

    /// @notice Internal function to handle the gate protection logic.
    /// @dev This function always returns true, signaling that any passerby is able to pass the gate.
    /// @return True, allowing any passerby to pass the gate.
    function _check(address /*passerby*/, bytes calldata /*data*/) internal pure override returns (bool) {
        return true; /// @todo check if optional.
    }
}
