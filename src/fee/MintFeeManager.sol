// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {TransferHelperUtils} from "../utils/TransferHelperUtils.sol";
import {IMintFeeManager} from "../interfaces/IMintFeeManager.sol";

contract MintFeeManager is IMintFeeManager {
    uint256 public immutable mintFee;
    address public immutable mintFeeRecipient;

    constructor(uint256 _mintFee, address _mintFeeRecipient) {
        // Set fixed finders fee
        if (_mintFee >= 0.1 ether) {
            revert MintFeeCannotBeMoreThanZeroPointOneETH(_mintFee);
        }
        if (_mintFeeRecipient == address(0) && _mintFee > 0) {
            revert CannotSetMintFeeToZeroAddress();
        }
        mintFeeRecipient = _mintFeeRecipient;
        mintFee = _mintFee;
    }

    function _handleFeeAndGetValueSent(uint256 _quantity) internal returns (uint256 ethValueSent) {
        ethValueSent = msg.value;

        // Handle mint fee
        if (mintFeeRecipient != address(0)) {
            uint256 totalFee = mintFee * _quantity;
            ethValueSent -= totalFee;
            if (!TransferHelperUtils.safeSendETHLowLimit(mintFeeRecipient, totalFee)) {
                revert CannotSendMintFee(mintFeeRecipient, totalFee);
            }
        }
    }
}
