// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {SNARK_SCALAR_FIELD} from "lean-imt/Constants.sol";
import "lean-imt/LeanIMT.sol";
import {
    LeafAlreadyExists,
    LeafCannotBeZero,
    LeafDoesNotExist,
    LeafGreaterThanSnarkScalarField,
    WrongSiblingNodes
} from "lean-imt/InternalLeanIMT.sol";

contract LeanIMTTest is Test {
    using LeanIMT for LeanIMTData;

    LeanIMTData private imt;

    function boundLeaf(uint256 leaf) private pure returns (uint256) {
        return bound(leaf, 1, SNARK_SCALAR_FIELD - 1);
    }

    function boundLeaves(uint256[] calldata leaves) private pure returns (uint256[] memory) {
        uint256[] memory boundedLeaves = new uint256[](leaves.length);
        for (uint256 i = 0; i < leaves.length; i++) {
            boundedLeaves[i] = boundLeaf(leaves[i]);
        }
        return boundedLeaves;
    }

    function test_RevertIf_InsertLeafGreaterThanSnarkScalarField() public {
        vm.expectRevert(LeafGreaterThanSnarkScalarField.selector);
        imt.insert(SNARK_SCALAR_FIELD);

        vm.expectRevert(LeafGreaterThanSnarkScalarField.selector);
        imt.insert(SNARK_SCALAR_FIELD + 1);
    }

    function test_RevertIf_InsertZeroLeaf() public {
        vm.expectRevert(LeafCannotBeZero.selector);
        imt.insert(0);
    }

    function testRevert_InsertDuplicateLeaf() public {
        imt.insert(1);
        vm.expectRevert(LeafAlreadyExists.selector);
        imt.insert(1);
    }

    function testFuzz_Insert(uint256 leaf) public {
        // revert if leaf out of bound already tested above
        leaf = boundLeaf(leaf);
        uint256 root = imt.insert(leaf);

        assertTrue(imt.has(leaf));
        assertEq(imt.indexOf(leaf), 0);
        assertEq(imt.root(), root);
        assertEq(imt.size, 1);
        assertEq(imt.depth, 0);
    }

    function test_RevertIf_InsertManyGreaterThanSnarkField() public {
        vm.expectRevert(LeafGreaterThanSnarkScalarField.selector);
        uint256[] memory leaves = new uint256[](1);
        leaves[0] = SNARK_SCALAR_FIELD;

        imt.insertMany(leaves);
    }

    function test_RevertIf_InsertManyZeroLeaf() public {
        vm.expectRevert(LeafCannotBeZero.selector);
        uint256[] memory leaves = new uint256[](1);
        leaves[0] = 0;

        imt.insertMany(leaves);
    }

    function test_RevertIf_InsertManyDuplicateLeaf() public {
        uint256[] memory leaves = new uint256[](2);
        leaves[0] = 1;
        leaves[1] = 1;

        vm.expectRevert(LeafAlreadyExists.selector);
        imt.insertMany(leaves);
    }

    function test_insertMany() public {
        uint256[] memory leaves = new uint256[](3);
        leaves[0] = 1;
        leaves[1] = 2;
        leaves[2] = 3;

        uint256 root = imt.insertMany(leaves);

        for (uint256 i = 0; i < leaves.length; i++) {
            assertTrue(imt.has(leaves[i]));
            assertEq(imt.indexOf(leaves[i]), i);
        }
        assertEq(imt.root(), root);
        assertEq(imt.size, 3);
        assertEq(imt.depth, 2);
    }

    function test_RevertIf_UpdateNewLeafGreaterThanSnarkScalarField() public {
        imt.insert(1);
        vm.expectRevert(LeafGreaterThanSnarkScalarField.selector);
        imt.update(1, SNARK_SCALAR_FIELD, new uint256[](0));

        vm.expectRevert(LeafGreaterThanSnarkScalarField.selector);
        imt.update(1, SNARK_SCALAR_FIELD + 1, new uint256[](0));
    }

    function test_RevertIf_UpdateNewLeafAlreadyExists() public {
        imt.insert(1);
        vm.expectRevert(LeafAlreadyExists.selector);
        imt.update(1, 1, new uint256[](0));
    }

    function test_RevertIf_UpdateOldLeafDoesNotExist() public {
        imt.insert(1);
        vm.expectRevert(LeafDoesNotExist.selector);
        imt.update(2, 3, new uint256[](0));
    }

    function testFuzz_Update(uint256 oldLeaf, uint256 newLeaf) public {
        // all revert cases already tested above, so forcing they can't happen while still fuzzing
        oldLeaf = boundLeaf(oldLeaf);
        newLeaf = boundLeaf(newLeaf);
        while (oldLeaf == newLeaf) {
            newLeaf = boundLeaf(newLeaf + 1);
        }

        imt.insert(oldLeaf);
        uint256 root = imt.update(oldLeaf, newLeaf, new uint256[](0));

        assertTrue(imt.has(newLeaf));
        assertFalse(imt.has(oldLeaf));
        assertEq(imt.indexOf(newLeaf), 0);
        assertEq(imt.root(), root);
        assertEq(imt.size, 1);
        assertEq(imt.depth, 0);
    }

    function test_FuzzRemove(uint256 leaf) public {
        leaf = boundLeaf(leaf);
        assertEq(imt.size, 0);
        imt.insert(leaf);
        uint256 root = imt.remove(leaf, new uint256[](0));

        assertFalse(imt.has(leaf));
        assertEq(imt.root(), root);
        // TODO: question: remove does not update size??
        assertFalse(imt.size == 0);
    }

    function test_RevertIf_IndexOfLeafDoesNotExist() public {
        vm.expectRevert(LeafDoesNotExist.selector);
        imt.indexOf(1);
    }
}
