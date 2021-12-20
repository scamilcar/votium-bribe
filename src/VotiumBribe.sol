// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IVotiumBribe {
    function depositBribe(address _token, uint256 _amount, bytes32 _proposal, uint256 _choiceIndex) external;
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract Incentive {
    
    address public VOTIUM_BRIBE = 0x19BBC3463Dd8d07f55438014b021Fb457EBD4595;
    
    address public incentiveToken;
    address public targetGauge;
    uint256 public amountPerVote;
    uint256 public voteChoiceIndex;
    
    uint256 public activePeriod;
    uint256 public WEEK = 86400 * 7;

    // Emitted when a '_depositor' deposits '_amount' '_incentiveToken'.
    event Deposited(address indexed _depositor, uint256 _amount);
    // Emitted when a vote is incentivized.
    event VoteIncentivized(bytes32 _proposal, uint256 _date);
    
    constructor (
        address _incentiveToken,
        uint256 _amountPerVote, 
        address _targetGauge, 
        uint256 _voteChoiceIndex
        ) {
        incentiveToken = _incentiveToken;
        amountPerVote = _amountPerVote;
        targetGauge = _targetGauge;
        // Set the Convex vote choice index to ensure this contract can only incentivize targetGauge.
        // After checking the IPFS URIs of past votes on vote.convexfinance.com,
        // it seems that gauge choices always have the same indexes so it should do the work.
        voteChoiceIndex = _voteChoiceIndex;
    }

    // Allows anyone to deposited a desired '_amount' of 'incentiveTokens' in this contract.
    // Refunds the depositor 'refund' if 'amount' is not a multiple of 'amountPerVote'.
    function depositIncentive(uint _amount) external returns (bool) {
        require(_amount >= amountPerVote, "Not enough tokens");
        uint256 refund = _amount % amountPerVote;
        uint256 deposit = _amount - refund;
        IERC20(incentiveToken).transferFrom(msg.sender, address(this), deposit);
        emit Deposited(msg.sender, deposit);
        return true;
    }

    // Deposits 'amountPerVote' of 'incentiveToken on Votium.
    // Reverts if called before 2 weeks have passed since the last call,
    // meaning that the vote has already been incentivized by this contract for this vote.
    // Important : Should be called for the first time just after the next Convex Snapshot gauge weight vote goes live
    // (Thursday 00:00 UTC every 2 weeks) so that it can only be called bi-weekly after that, thus only allowing 1 bribe of 'amountPerVote' per '_proposal'.
    function incentivizeVote(bytes32 _proposal) external returns (bool) {
        require(block.timestamp >= activePeriod + WEEK * 2, "Vote already incentivized.");
        activePeriod = block.timestamp;
        IERC20(incentiveToken).approve(VOTIUM_BRIBE, amountPerVote);
        IVotiumBribe(VOTIUM_BRIBE).depositBribe(incentiveToken, amountPerVote, _proposal, voteChoiceIndex);
        emit VoteIncentivized(_proposal, activePeriod);
        return true;
    }



}
