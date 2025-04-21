// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
PropertyShareToken (PSH) is a revenue-sharing token designed for use in property or
asset-backed smart contracts. The PSH is represents the ownership or participant right
in a shared property, where property will generate the profit/rent in USDC. The holders is 
entitled to receive periodic distributions in USDC based on their token holdings.

The token integrates holder tracking, USDC fund distribution, and community-based
approval mechanisms.
*/
contract PropertyShareToken is ERC20("Property Share Token", "PSH"), Ownable {
    address payable public treasure;
    IERC20 public USDC;
    uint256 public reserve; // reserved fund in USDC (for maintainance)
    uint256 public approvalWeight; // Total approved token weight

    mapping(address => bool) private isHolder;
    mapping(address => bool) public hasApproved;
    address[] private holders;

    event Distribute(address holder, uint256 amount);
    event RentReceived(address sender, uint256 amount);

    constructor(uint256 _initSupply, uint256 _reserve) Ownable(msg.sender) {
        treasure = payable(address(this));
        reserve = _reserve * 10 ** 6;
        USDC = IERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238); // usdc address
        _mint(msg.sender, _initSupply * 10 ** decimals());
    }

    receive() external payable {}

    function depositRent(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        bool success = USDC.transferFrom(msg.sender, address(this), amount);
        require(success, "USDC transfer failed");
        emit RentReceived(msg.sender, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 2;
    }

    function getTreasureBalance() external view returns (uint256) {
        return USDC.balanceOf(treasure);
    }

    function _addHolder(address account) internal {
        if (!isHolder[account] && balanceOf(account) > 0) {
            isHolder[account] = true;
            holders.push(account);
        }
    }

    function _removeHolder(address account) internal {
        if (isHolder[account] && balanceOf(account) == 0) {
            isHolder[account] = false;
        }
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        super._update(from, to, value);

        if (from != address(0)) {
            _removeHolder(from);
        }
        if (to != address(0)) {
            _addHolder(to);
        }
    }

    function getHolders() external view returns (address[] memory) {
        return holders;
    }

    function resetApprovals() internal {
        for (uint256 i = 0; i < holders.length; ++i) {
            hasApproved[holders[i]] = false;
        }
        approvalWeight = 0;
    }

    function distributeFund() public onlyOwner returns (bool) {
        require(approvalWeight > totalSupply() / 2, "Majority approval required");
        bool result = _distributeFund();
        resetApprovals();
        return result;
    }

    function approveDistribution() external {
        uint256 balance = balanceOf(msg.sender);
        require(balance > 0, "Must hold tokens to approve");
        require(!hasApproved[msg.sender], "Already approved");

        hasApproved[msg.sender] = true;
        approvalWeight += balance;
    }

    function _distributeFund() internal virtual returns (bool) {
        uint256 treasureBalance = USDC.balanceOf(treasure);
        require(treasureBalance > reserve, "not enough USDC");

        uint256 availableFund = treasureBalance - reserve;
        address[] memory holdersList = holders;

        for (uint256 i = 0; i < holdersList.length; ++i) {
            if (balanceOf(holdersList[i]) > 0) {
                uint256 amount = availableFund * (balanceOf(holdersList[i]) * 10000 / totalSupply()) / 10000;
                _payUSDC(holdersList[i], amount);
                emit Distribute(holdersList[i], amount);
            }
        }
        return true;
    }

    function _payUSDC(address toAddress, uint256 amount) internal {
        bool success = USDC.transfer(toAddress, amount);
        require(success, "failed transfer usdc");
    }
}
