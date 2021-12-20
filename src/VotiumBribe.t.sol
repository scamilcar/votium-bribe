// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/ds-test/src/test.sol";
import "./VotiumBribe.sol";

contract VotiumBribeTest is DSTest {

    address constant FLX = 0x6243d8CEA23066d098a15582d81a598b4e8391F4;
    uint256 constant AMOUNT_PER_VOTE = 50*10**18;
    
    Incentive incentive;
    IERC20 flx;

    function setUp() public {
        incentive = new Incentive(FLX, AMOUNT_PER_VOTE, address(0x1));
        flx = IERC20(FLX);
    }
    
    // Should deposit 'amount' in the contract.
    function test_depositIncentive() public {
        uint256 amount = 100*10**18;
        uint256 preBalance = flx.balanceOf(address(incentive));
        flx.approve(address(incentive), amount);
        incentive.depositIncentive(amount);
        uint256 postBalance = flx.balanceOf(address(incentive));
        assertEq(preBalance + amount, postBalance);
    }

    // Should test if it is possible to deposit 'amount' in the contract and fail since depositing less than amountPerVote.
    function testFail_depositIncentive() public {
        uint256 amount = 40*10**18;
        flx.approve(address(incentive), amount);
        incentive.depositIncentive(amount);
    }

    function test_incentivizeGauge() public {
        uint256 amount = 100*10**18;
        flx.approve(address(bribe), amount);
        incentive.depositIncentive(amount);
        uint256 preBalanceBribe = spell.balanceOf(address(bribe));
        uint256 preBalanceCRVBribeV2 = spell.balanceOf(BRIBE_V2);
        incentive.incentivizeVote();
        uint256 postBalanceBribe = spell.balanceOf(address(bribe));
        uint256 postBalanceCRVBribeV2 = spell.balanceOf(BRIBE_V2);
        assertEq(preBalanceBribe - AMOUNT_PER_VOTE, postBalanceBribe);
        assertEq(preBalanceCRVBribeV2 + AMOUNT_PER_VOTE, postBalanceCRVBribeV2);

}
