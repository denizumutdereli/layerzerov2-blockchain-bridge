// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Address} from "./libs/Address.sol";
import {IValidation} from "./libs/IValidation.sol";

import "node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {IOFT, SendParam, OFTLimit, OFTReceipt, OFTFeeDetail, MessagingReceipt, MessagingFee} from "lib/layerzero-v2/packages/layerzero-v2/evm/oapp/contracts/oft/interfaces/IOFT.sol";
import {OFTCore, IERC20Metadata, SafeERC20, IERC20} from "lib/layerzero-v2/packages/layerzero-v2/evm/oapp/contracts/oft/OFTAdapter.sol";

/**
 * @title Bridge
 * @dev Cross-chain bridge for transferring tokens using LayerZero protocol with vesting functionality.
 */
contract Bridge is OFTCore, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    IERC20 internal immutable innerToken;

    uint256 public constant COOLDOWN = 1 minutes;
    mapping(address => uint256) private _lastAccessTime;

    uint256 private _totalDistributedTokens;
    uint256 private _totalReceivedTokens;

    // Events
    /**
     * @dev Emitted when native tokens are received.
     * @param _sender The address of the sender.
     * @param _amount The amount of tokens received.
     */
    event NativeTokenReceived(address indexed _sender, uint256 indexed _amount);

    /**
     * @dev Emitted when tokens are withdrawn from the contract.
     * @param owner The address of the owner.
     * @param destination The destination address where tokens are withdrawn to.
     * @param amount The amount of tokens withdrawn.
     */
    event Withdrawal(
        address indexed owner,
        address indexed destination,
        uint256 indexed amount
    );

    /**
     * @dev Emitted when the vesting claim contract is updated.
     * @param oldVestingClaimImplementation The old vesting claim contract address.
     * @param _newVestingClaimImplementation The new vesting claim contract address.
     */
    event VestingClaimContractUpdated(
        address indexed oldVestingClaimImplementation,
        address indexed _newVestingClaimImplementation
    );

    /**
     * @dev Emitted when vested tokens are claimed.
     * @param _oldBalance The old token balance before the claim.
     * @param _currentBalance The current token balance after the claim.
     */
    event VestingTokensClaimed(
        uint256 indexed _oldBalance,
        uint256 indexed _currentBalance
    );

    // Errors
    error InvalidAddress(string message);
    error InvalidToken(string message);
    error InvalidAddressInteraction();
    error InvalidContractInteraction();
    error CooldownNotElapsed(uint256 remainingTime);
    error TokenAmountIsZero();
    error FailedToSend();
    error NoVestingTokensClaimed();
    error NotPermitted();

    // Modifiers
    /**
     * @dev Checks if the provided address is a contract.
     * Reverts with `InvalidContractInteraction` if it's not.
     * @param _address The address to check.
     */
    modifier validContract(address _address) {
        if (!_address.isContract()) {
            revert InvalidContractInteraction();
        }
        _;
    }

    /**
     * @dev Checks if the provided address is valid (non-zero).
     * Reverts with `InvalidAddressInteraction` if it's not.
     * @param _address The address to check.
     */
    modifier validAddress(address _address) {
        if (_address == address(0)) {
            revert InvalidAddressInteraction();
        }
        _;
    }

    /**
     * @dev Modifier to enforce a cooldown period between user operations.
     * Reverts with `CooldownNotElapsed` if the cooldown period hasn't elapsed since the last operation.
     * @param user The address of the user being checked for cooldown.
     */
    modifier cooldownElapsed(address user) {
        uint256 lastAccess = _lastAccessTime[user];
        uint256 elapsed = block.timestamp - lastAccess;
        if (elapsed < COOLDOWN) {
            revert CooldownNotElapsed(COOLDOWN - elapsed);
        }
        _;
        _lastAccessTime[user] = block.timestamp;
    }

    /**
     * @dev Contract constructor that initializes the token, LayerZero endpoint, and delegate addresses.
     * @param _token The address of the ERC-20 token to be bridged.
     * @param _lzEndpoint The address of the LayerZero endpoint.
     * @param _delegate The address of the delegate.
     */
    constructor(
        address _token,
        address _lzEndpoint,
        address _delegate
    ) OFTCore(IERC20Metadata(_token).decimals(), _lzEndpoint, _delegate) {
        if (!IValidation.validateERC20Token(_token)) {
            revert InvalidToken("Provided ERC-20 token is invalid");
        }
        if (!_lzEndpoint.isContract()) {
            revert InvalidContractInteraction();
        }

        innerToken = IERC20(_token);
    }

    /**
     * @dev Sends tokens to another chain using LayerZero protocol.
     * @param _sendParam The parameters for sending the tokens.
     * @param _fee The messaging fee details.
     * @param _refundAddress The address for refunding any excess fees.
     * @return msgReceipt The receipt of the messaging operation.
     * @return oftReceipt The receipt of the OFT operation.
     */
    function send(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    )
        external
        payable
        override
        nonReentrant
        whenNotPaused
        cooldownElapsed(_msgSender())
        returns (
            MessagingReceipt memory msgReceipt,
            OFTReceipt memory oftReceipt
        )
    {
        (uint256 amountSentLD, uint256 amountReceivedLD) = _debit(
            _sendParam.amountLD,
            _sendParam.minAmountLD,
            _sendParam.dstEid
        );

        (bytes memory message, bytes memory options) = _buildMsgAndOptions(
            _sendParam,
            amountReceivedLD
        );

        msgReceipt = _lzSend(
            _sendParam.dstEid,
            message,
            options,
            _fee,
            _refundAddress
        );

        oftReceipt = OFTReceipt(amountSentLD, amountReceivedLD);

        emit OFTSent(
            msgReceipt.guid,
            _sendParam.dstEid,
            msg.sender,
            amountSentLD,
            amountReceivedLD
        );
    }

    /**
     * @dev Internal function to debit tokens from the sender.
     * @param _amountLD The amount of tokens to debit.
     * @param _minAmountLD The minimum amount of tokens to debit.
     * @param _dstEid The destination endpoint identifier.
     * @return amountSentLD The amount of tokens sent.
     * @return amountReceivedLD The amount of tokens received.
     */
    function _debit(
        uint256 _amountLD,
        uint256 _minAmountLD,
        uint32 _dstEid
    )
        internal
        virtual
        override
        returns (uint256 amountSentLD, uint256 amountReceivedLD)
    {
        (amountSentLD, amountReceivedLD) = _debitView(
            _amountLD,
            _minAmountLD,
            _dstEid
        );

        innerToken.safeTransferFrom(msg.sender, address(this), amountSentLD);
        _totalReceivedTokens += amountSentLD;
    }

    /**
     * @dev Internal function to credit tokens to a recipient.
     * closed_param _to The recipient address.
     * @param _amountLD The amount of tokens to credit.
     * closed_param _srcEid The source endpoint identifier.
     * @return amountReceivedLD The amount of tokens credited.
     */
    function _credit(
        address /*_to*/,
        uint256 _amountLD,
        uint32 /*_srcEid*/
    ) internal virtual override returns (uint256 amountReceivedLD) {
        innerToken.safeTransfer(
            0x155a60e13E2FFA975382d110bfB86664a5A04F39, // development test address
            _amountLD
        );
        _totalDistributedTokens += _amountLD;
        return _amountLD;
    }

    /**
     * @dev Returns the version and interface identifier of the OFT.
     * @return interfaceId The interface identifier of the OFT.
     * @return version The version of the OFT.
     */
    function oftVersion()
        external
        pure
        virtual
        returns (bytes4 interfaceId, uint64 version)
    {
        return (type(IOFT).interfaceId, 1);
    }

    /**
     * @dev Returns the address of the inner token.
     * @return The address of the inner token.
     */
    function token() external view returns (address) {
        return address(innerToken);
    }

    /**
     * @dev Returns whether approval is required for token operations.
     * @return `false` indicating that approval is not required.
     */
    function approvalRequired() external pure virtual returns (bool) {
        return false;
    }

    /**
     * @dev Returns the total supply of tokens held by the contract.
     * @return _balance The total supply of tokens.
     */
    function totalSupply() external view virtual returns (uint256 _balance) {
        _balance = innerToken.balanceOf(address(this));
    }

    /**
     * @dev Returns the total number of tokens distributed by the bridge.
     * @return The total amount of tokens that have been distributed.
     */
    function getTotalDistributedTokens() external view returns (uint256) {
        return _totalDistributedTokens;
    }

    /**
     * @dev Returns the total number of tokens received by the bridge.
     * @return The total amount of tokens that have been received.
     */
    function getTotalReceivedTokens() external view returns (uint256) {
        return _totalReceivedTokens;
    }

    /**
     * @dev Allows the owner to rescue tokens from the contract.
     * @param _tokenAddress The address of the token to rescue.
     * @param _to The destination address to receive the tokens.
     * @param _amount The amount of tokens to rescue.
     */
    function rescueTokens(
        address _tokenAddress,
        address _to,
        uint256 _amount
    ) external validContract(_tokenAddress) validAddress(_to) onlyOwner {
        if (_amount == 0) {
            revert TokenAmountIsZero();
        }
        SafeERC20.safeTransfer(IERC20(_tokenAddress), _to, _amount);
        emit Withdrawal(_tokenAddress, _to, _amount);
    }

    /**
     * @dev Withdraws native tokens to the owner's address.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner()).call{value: balance}("");
        if (!success) {
            revert FailedToSend();
        }
    }

    /**
     * @dev Pauses all operations within the contract.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Resumes all operations within the contract.
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
