 // SPDX-License-Identifier: CC0-1.0
 
 pragma solidity ^0.8.0;

 interface IERC721YY {

    /// Logged when the NFT is listed,delisted or changed listing
    /// @notice Emitted when the NFT is listed,delisted or changed listing
    /// The zero price indicates that NFT is not listing
    /// @param tokenId The NFT to change sale info for
    /// @param price The listing price
    /// @param expires The listing expires
    event OnSaleInfo(uint256 indexed tokenId,uint256 price,uint64 expires);

    /// Logged when the NFT is traded
    /// @notice Emitted when the NFT is traded
    /// The price cannot be 0
    /// @param tokenId The NFT to be traded for
    /// @param price The trading price
    /// @param buyer The buyer of the NFT
    /// @param seller The seller of the NFT
    event SwapInfo(uint256 indexed tokenId, uint256 price, address indexed buyer,address indexed seller);
    
    /// @notice Set or change listing info of the NFT
    /// @dev The price cannot be 0
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to set or change listing for
    /// @param price  The listing price
    /// @param expires The listing expires
    function setList(uint256 tokenId,uint256 price,uint64 expires) external;

    /// @notice Delist NFT
    /// @dev caller must be owner or approved
    /// @param tokenId  The delisted NFT
    function cancelList(uint256 tokenId) external;

    /// @notice Buyer accept the price of the listing NFT and the NFT is traded
    /// @param tokenId The NFT to be traded for
    function acceptList(uint256 tokenId) external payable;
    
    /// @notice Get the price of the listing NFT
    /// @dev The zero price indicates that NFT is not listing
    /// @param tokenId The NFT to be listed for
    /// @return The listing price of the NFT
    function listPriceAt(uint256 tokenId) external returns(uint256);


    /// @notice Get the expires of the listing NFT
    /// @dev The zero expires indicates that NFT is not listing
    /// @param tokenId The NFT to be listed for
    /// @return The listing expires of the NFT
    function listExpiresOf(uint256 tokenId) external returns (uint64);   

}
