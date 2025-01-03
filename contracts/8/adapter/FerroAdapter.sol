// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAdapter.sol";
import "../interfaces/ISynapse.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/ILendingPool.sol";

import "../libraries/SafeERC20.sol";

contract FerroAdapter is IAdapter {
    // address constant WETH_e = 0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB;
    // address constant avETH = 0x53f7c5869a859F0AeC3D334ee8B4Cf01E3492f21;
    // address constant avETH_nETH = 0x77a7e60555bC18B4Be44C181b2575eee46212d44;
    // address constant aaveLendingPoolV2 =
    //     0x4F01AeD16D97E3aB5ab2B501154DC9bb0F1A5A2C;
    // uint256 constant AVAX_CCHAIN_ID = 43114;

    function _ferroSwap(
        address to,
        address pool,
        bytes memory moreInfo
    ) internal {
        (address fromToken, address toToken, uint256 deadline) = abi.decode(
            moreInfo,
            (address, address, uint256)
        );
        

        uint256 amountOut = _internalSwap(fromToken, toToken, pool, deadline);

        if (to != address(this)) {
            SafeERC20.safeTransfer(IERC20(toToken), to, amountOut);
        }
    }

    function _internalSwap(
        address fromToken,
        address toToken,
        address pool,
        uint256 deadline
    ) internal returns (uint256 amountOut) {
        uint8 fromTokenIndex = ISynapse(pool).getTokenIndex(fromToken);
        uint8 toTokenIndex = ISynapse(pool).getTokenIndex(toToken);
        uint256 sellAmount = IERC20(fromToken).balanceOf(address(this));
        // approve
        SafeERC20.safeApprove(IERC20(fromToken), pool, sellAmount);

        // swap
        amountOut = ISynapse(pool).swap(
            fromTokenIndex,
            toTokenIndex,
            sellAmount,
            0,
            deadline
        );
    }

    

    function sellBase(
        address to,
        address pool,
        bytes memory moreInfo
    ) external override {
        _ferroSwap(to, pool, moreInfo);
    }

    function sellQuote(
        address to,
        address pool,
        bytes memory moreInfo
    ) external override {
        _ferroSwap(to, pool, moreInfo);
    }

    receive() external payable {
        require(msg.value > 0, "receive error");
    }
}
