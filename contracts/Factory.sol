// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Main.sol";

contract Factory {
    uint256 public count;
    mapping(uint256 => address) public papers;

    /**
     * @notice Anyone can create an paper, but it may be subject to change
     */
    function createPaper(string memory name, string memory symbol, uint256 price) public returns (address) {
        Main newMain = new Main(name, symbol, msg.sender, price);
        papers[count] = address(newMain);
        count += 1;
        return address(newMain);
    }
}
