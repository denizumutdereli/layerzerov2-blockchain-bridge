// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// imports
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20, ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MockUSDT
 * @dev A mock implementation of an ERC20 token named "Mock USDT" with symbol "USDT" 
 * for testing and development purposes. The token has 6 decimal places 
 * and includes minting and burning functionalities. It extends OpenZeppelin's ERC20,
 * ERC20Burnable, and Ownable contracts.
*/

contract MockUSDT is Ownable, ERC20, ERC20Burnable {
    using SafeERC20 for IERC20;

    /**
     * @dev Constructor that mints 50,000,000,000 USDT tokens to the deployer's address.
     */
    constructor() ERC20("Mock USDT", "USDT") {
        _mint(msg.sender, 50000000000 * 10 ** decimals());
    }

    /**
     * @dev Mint new tokens.
     * @param to The address to receive the minted tokens.
     * @param amount The amount of tokens to be minted.
     */
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    /**
     * @dev Override the decimals function to set the number of decimals to 6.
     * @return The number of decimals (6).
     */
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
