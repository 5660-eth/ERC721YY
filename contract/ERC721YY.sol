// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./ERC721QS.sol";
import "./IERC721YY.sol";

abstract contract ERC721YY is ERC721QS, IERC721YY {

    struct ListInfo {uint256 price;uint64 expires;}

    mapping (uint256  => ListInfo) internal _sellers;

    /*///////////////////////////////////////////////////////////////
                            Set Royalties                     
    //////////////////////////////////////////////////////////////*/
    /// Or can adopt EIP-2981
    /// Address of the contract owner
    address feeOperator;
    /// Address to receive the copyright fee
    address payable public feeRecipient;
    /// Copyright fee rate ( e.g. 100 for 1%)
    uint256 public feeRate;

    constructor(string memory name_, string memory symbol_) payable ERC721(name_, symbol_) {
        feeOperator = msg.sender;
    }

    /// Set the address that will receive the copyright fee
    function setFeeRecipient(address payable recipient) public {
        /// Only the contract owner can set the copyright fee recipient
        require(msg.sender == feeOperator, "Only the contract owner can set the copyright fee recipient");
        feeRecipient = recipient;
    }

    /// Set the copyright fee rate
    function setfeeRate(uint256 rate) public {
        /// Only the contract owner can set the copyright fee rate
        require(msg.sender == feeOperator, "Only the contract owner can set the copyright fee rate");
        /// The rate must be between 0 and 1,0000 (inclusive)
        require(rate >= 0 && rate <= 10000, "Copyright fee rate must be between 0 and 10,000");
        feeRate = rate;
    }

    function getRate() public virtual returns(uint256){
        return feeRate;
    }

    /*///////////////////////////////////////////////////////////////
                    Functions related to list                    
    //////////////////////////////////////////////////////////////*/

    /// @notice Set or change listing info of the NFT
    /// @dev The price cannot be 0
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to set or change listing for
    /// @param price  The listing price
    /// @param expires The listing expires
    function setList(uint256 tokenId,uint256 price,uint64 expires) public virtual{
        ///@dev Consider compatibility with ERC721QS/EIP6147, when there is a guard, the order cannot be placed.
        ///++address guard=guardOf(tokenId);
        ///++require(guard==address(0),"token has guard");
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721YY: transfer caller is not owner nor approved");
        ListInfo storage info =  _sellers[tokenId];
        require(price>0,"price can not be set to 0");
        info.price=price;
        info.expires=expires;
        emit OnSaleInfo(tokenId,price,expires); 
    }

    /// @notice Delist NFT
    /// @dev caller must be owner or approved
    /// @param tokenId The delisted NFT
    function cancelList(uint256 tokenId) public virtual {
         require(isOnSale(tokenId),"not on sale");
         require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721YY: transfer caller is not owner nor approved");
         delete _sellers[tokenId];
         emit OnSaleInfo(tokenId,0,0);
    }

    /// @notice Query whether the NFT is for sale
    /// @return Whether the NFT is for sale
    function isOnSale(uint256 tokenId) internal virtual returns(bool){
        if(_sellers[tokenId].price > 0 && _sellers[tokenId].expires > block.timestamp){
            return true;
        }
        else{
            return false;
        }
    }

    /// @notice Get the price of the listing NFT
    /// @dev The zero price indicates that NFT is not listing
    /// @param tokenId The NFT to be listed for
    /// @return The listing price of the NFT
    function listPriceAt(uint256 tokenId) public virtual returns(uint256){
        if( isOnSale(tokenId)){
            return _sellers[tokenId].price;
        }
        else{
            return 0;
        }
       
    }

    /// @notice Get the expires of the listing NFT
    /// @dev The zero expires indicates that NFT is not listing
    /// @param tokenId The NFT to be listed for
    /// @return The listing expires of the NFT
    function listExpiresOf(uint256 tokenId) public returns (uint64){
        if(isOnSale(tokenId)){
            return _sellers[tokenId].expires;
        }
        else{
            return 0;
        }
    }

    /// @notice Buyer accept the price of the listing NFT and the NFT is traded
    /// @param tokenId The NFT to be traded for
    function acceptSwap(uint256 tokenId) public payable virtual {

        address sender = _msgSender();
        address owner = ownerOf(tokenId);
        require(isOnSale(tokenId), "Token is not on sale");
        /// Check that the caller is not the owner of the token
        require(owner != sender, "ERC721YY: owner cannot accept a swap for their own token");
        uint256 amount = listPriceAt(tokenId);
        /// Check that the caller has transferred the required amount of Ether to the contract.
        require(msg.value == amount, "Incorrect amount of Ether transferred");
        /// Check that the contract has enough Ether to pay for the transfers

        ///++ require(address(this).balance >= amount, "Not enough Ether in contract to complete the transfer");

        /// Convert the token owner's address to a payable type to allow them to receive the payment
        address payable tokenOwner = payable(owner);
        /// Calculate the copyright fee based on the sale price and the fee rate
        uint256 copyrightFee = amount * feeRate / 10000;
        uint256 sellerGetFee = amount - copyrightFee;
        /// Remove the token from the list of tokens for sale
        delete _sellers[tokenId];
        /// Transfer the copyright fee to the specified recipient
        feeRecipient.transfer(copyrightFee); 
        /// Transfer the sale amount minus the copyright fee to the token owner
        tokenOwner.transfer(sellerGetFee);
        /// Transfer ownership of the token to the buyer
        _transfer(tokenOwner, sender, tokenId);
        /// OR _safeTransfer(owner,sender,tokenId,"swap success");
        emit SwapInfo(tokenId, amount, sender,tokenOwner);
    }

    function _beforeTokenTransfer(address from,address to,uint256 tokenId,uint256 batchSize) internal virtual override{
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        if(isOnSale(tokenId))
            delete  _sellers[tokenId];
            emit OnSaleInfo(tokenId,0,0);
    }

///Rewrite the `updateGuard` function in 721QS, when updating the guard, clear the pending order information
/*
    function updateGuard(uint256 tokenId,address newGuard,bool allowNull) internal virtual override {
        super.updateGuard(tokenId,newGuard,allowNull);
        delete _sellers[tokenId];
    }
*/

    /*///////////////////////////////////////////////////////////////
                    Functions related to make offer                    
    //////////////////////////////////////////////////////////////*/

    struct OfferInfo {uint256 price;uint64 expires;}

    mapping (uint256 => mapping (address => OfferInfo))  _offers;

    event OnOfferInfo(uint256 indexed tokenId, uint256 price,uint64 expires,address indexed buyer);

    /// @notice Set or change the offer for the NFT
    /// @dev The price cannot be 0
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId The NFT to make offer for
    /// @param price  The offer price
    /// @param expires The offer expires
    function makeOffer(uint256 tokenId, uint256 price,uint64 expires) public payable {
        require(price>0,"price can not be set to 0");
        require(msg.value == price, "Insufficient ether to make offer");
        address payable addresspayable = payable (address(this));
        addresspayable.transfer(price);
        _offers[tokenId][msg.sender] = OfferInfo({
            price: price,
            expires: expires 
            });
        emit OnOfferInfo(tokenId, price, expires,msg.sender);
    ///Offer storage offer =  _offers[tokenId][msg.sender];
    ///offer.price = price;
    ///offer.expires = expires;
    }

    /// @notice Query whether the buyer has made an offer for that NFT
    /// @return Whether the buyer has made an offer for that NFT
    function isOnOffer(uint256 tokenId, address buyer) internal virtual returns(bool){
        OfferInfo storage offer = _offers[tokenId][buyer];
        if(offer.price > 0&&offer.expires > block.timestamp){
            return true;
        }
        else{
            return false;
        }
    }

    /// @notice Seller accept the offer price of the NFT and the NFT is traded
    /// @param tokenId The NFT to be traded for
    /// @param buyer The buyer making an offer
    function acceptOffer(uint256 tokenId, address buyer) public payable{
        ///@dev Consider compatibility with ERC721QS/EIP6147, when there is a guard, the owner cannot `acceptOffer`
        ///require(guardOf(tokenId)==address(0);
        require(ownerOf(tokenId) == msg.sender, "Only the owner of the token can accept offers");
        OfferInfo storage offer = _offers[tokenId][buyer];
        require(isOnOffer(tokenId,buyer), "Offer does not exist");
        require(address(this).balance>=offer.price,"Not enough Ether in contract to complete the transfer");
        uint256 copyrightFee = offer.price * feeRate / 10000;
        uint256 sellerGetFee = offer.price - copyrightFee;
        delete _offers[tokenId][buyer];
        address payable sender =payable(msg.sender);
        sender.transfer(sellerGetFee);
        feeRecipient.transfer(copyrightFee); 
        _transfer(msg.sender, buyer, tokenId);

        emit SwapInfo(tokenId, offer.price, buyer,msg.sender);
    }

    /// @notice Cancel offer on the NFT
    /// @dev Offer need to exist
    /// @param tokenId  The NFT to cancel offer on 
    function cancelOffer(uint256 tokenId) public payable{
        require(isOnOffer(tokenId,msg.sender), "Offer does not exist");
        OfferInfo storage offer = _offers[tokenId][msg.sender];
        address  payable sender=payable(msg.sender);
        uint256 price = offer.price;
        require(address(this).balance>=offer.price,"Not enough Ether in contract to complete the transfer");
        delete _offers[tokenId][msg.sender];
        sender.transfer(price);
        emit OnOfferInfo(tokenId, 0, 0,msg.sender);
    }

    /// @notice Query the buyer's offer price for the NFT
    /// @dev The zero price indicates that buyer dose not make an offer for the NFT
    /// @param tokenId The NFT to be maked offer for
    /// @param buyer the buyer's address
    /// @return The buyer's offer price for the NFT
    function offerPriceAt(uint256 tokenId, address buyer) public virtual returns(uint256){
        OfferInfo storage offer = _offers[tokenId][buyer];
        if(isOnOffer(tokenId,buyer)){
            return offer.price;
        }
        else{
            return 0;
        }
    }

    /// @notice Query the buyer's offer expires for the NFT
    /// @dev The zero expires indicates that buyer dose not make an offer for the NFT
    /// @param tokenId The NFT to be maked offer for
    /// @param buyer the buyer's address
    /// @return The buyer's offer expires for the NFT
    function offerExpiresOf(uint256 tokenId, address buyer) public virtual returns(uint64){
        OfferInfo storage offer = _offers[tokenId][buyer];
        if(isOnOffer(tokenId,buyer)){
            return offer.expires;
        }
        else{
            return 0;
        }
    }

}
