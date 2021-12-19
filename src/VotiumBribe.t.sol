// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./VotiumBribe.sol";

contract VotiumBribeTest is DSTest {
    VotiumBribe bribe;

    function setUp() public {
        bribe = new VotiumBribe();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
