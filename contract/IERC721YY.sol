 // SPDX-License-Identifier: CC0-1.0
 
 pragma solidity ^0.8.0;

 interface IERC721YY {

    /// Logged when the guard of an NFT is changed 
    /// @notice Emitted when  the `guard` is changed
    /// The zero address for guard indicates that there is no guard address
   event OnSaleInfo(uint256 indexed tokenId,uint256 price,uint64 expires);

   event SawpInfo(uint256 indexed tokenId, uint256 price, address indexed tokenOwner,address indexed sender);
    
    /// @notice Remove the guard of the NFT
    /// Only guard can remove its own guard role
    /// @dev The guard address is set to 0 address
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to remove the guard address for
    function setSwap(uint256 tokenId,uint256 price,uint64 expires) external;

    function revokeSwap(uint256 tokenId) external;

        
    /// @notice Transfer the NFT and remove its guard role
    /// @dev The NFT is transferred to `to`and the guard address is set to 0 address
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to get transferred for
    function acceptSwap(uint256 tokenId) external payable;
    
    /// @notice  Owner can set guard of the NFT and guard can modifiy guard of the NFT
    /// If the NFT has a guard role, the owner of the NFT cannot modify guard
    /// @dev The newGuard can not be zero address
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to get the guard address for
    function priceAt(uint256 tokenId) external returns(uint256);

    /// @notice Get the guard address of the NFT
    /// @dev The zero address indicates that there is no guard
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to get the guard address for
    /// @return The guard address for the NFT
   function expiresOf(uint256 tokenId) external returns (uint64);   
}
