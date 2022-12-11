// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./ERC721QS.sol";
import "./IERC721YY.sol";

abstract contract ERC721YY is ERC721QS, IERC721YY {

    struct SwapInfo 
    {
        uint256 price;   // NFT价格，考虑数据类型准确与否,价格单位为wei;
        uint64 expires; // unix timestamp, price expires
    }

    mapping (uint256  => SwapInfo) internal _sellers;

    // Address of the contract owner
    address public feeOperator;
    // Address to receive the copyright fee
    address payable public feeRecipient;

    /// 注意，solidity中无小数，用0-1000；
    // Copyright fee rate ( e.g. 100 for 10%)
    uint256 public feeRate;

    constructor(string memory name_, string memory symbol_) payable ERC721(name_, symbol_) {
        feeOperator = msg.sender;
    }

    // Set the address that will receive the copyright fee
    function setFeeRecipient(address payable recipient) public {
        // Only the contract owner can set the copyright fee recipient
        require(msg.sender == feeOperator, "Only the contract owner can set the copyright fee recipient");
        feeRecipient = recipient;
    }

    // Set the copyright fee rate
    function setfeeRate(uint256 rate) public {
        // Only the contract owner can set the copyright fee rate
        require(msg.sender == feeOperator, "Only the contract owner can set the copyright fee rate");
        // The rate must be between 0 and 1,000 (inclusive)
        require(rate >= 0 && rate <= 1000, "Copyright fee rate must be between 0 and 1,000"); ///版权税率区间，0-1000,10意味着1%
        feeRate = rate;
    }
    ///查询版权税,前面已经定义

    function getRate() public virtual returns(uint256){
        return feeRate;
    }

    function setSwap(uint256 tokenId,uint256 price,uint64 expires) public virtual{
        ///----和721QS兼容，有guard时，无法挂单；（或者有guard时,只有guard能挂单，本方法复杂些,暂未考虑）
        address guard=guardOf(tokenId);
        require(guard==address(0),"token has guard");
        ///----------
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721YY: transfer caller is not owner nor approved");
        SwapInfo storage info =  _sellers[tokenId];
        require(price>0,"price can not be set to 0");
        info.price=price;
        info.expires=expires;
        emit OnSaleInfo(tokenId,price,expires); 
    }

    function revokeSwap(uint256 tokenId) public virtual {
         require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721YY: transfer caller is not owner nor approved");
         delete _sellers[tokenId];
         emit OnSaleInfo(tokenId,0,0);
    }

///查询NFT是否在售
    function isOnSale(uint256 tokenId) internal virtual returns(bool){  ///选择public可视性亦可以
        if(_sellers[tokenId].price > 0 && _sellers[tokenId].expires >=  block.timestamp)
        {
            return true;
        }
        else{
            return false;
        }
    }

///如果在售，返回价格；否则，返回0；
    function priceAt(uint256 tokenId) public virtual returns(uint256){
        if( isOnSale(tokenId)){
            return _sellers[tokenId].price;
        }
        else{
            return 0;
        }
       
    }

///如果在售，返回期限；否则，返回0；
    function expiresOf(uint256 tokenId) public returns (uint64){
        if(isOnSale(tokenId)){
            return _sellers[tokenId].expires;
        }
        else{
            return 0;
        }
    }

    function acceptSwap(uint256 tokenId) public payable virtual {

        address sender = _msgSender();
        address owner =ownerOf(tokenId);
        //检查NFT是否在售
        require(isOnSale(tokenId), "Token is not on sale");

        // Check that the caller is not the owner of the token
        require(owner != sender, "ERC721YY: owner cannot accept a swap for their own token");

        uint256 amount = priceAt(tokenId);

        // Check that the caller has transferred the required amount of Ether to the contract。检查调用者是否转移了足够的ETH到合约;
        require(msg.value >= amount, "Incorrect amount of Ether transferred");
        
        // Check that the contract has enough Ether to pay for the transfers
        require(address(this).balance >= amount, "Not enough Ether in contract to complete the transfer");//注意address(this).balance

        // Convert the token owner's address to a payable type to allow them to receive the payment

        address payable tokenOwner = payable(owner);

        /// Calculate the copyright fee based on the sale price and the fee rate
        uint256 copyrightFee = amount * feeRate / 1000;    ///solidity0.8.0以上默认采用了checked模式，结果溢出会出现失败异常回退。
        ///计算NFT所有者能够得到的收入
        uint256 sellerGetFee = amount * 1000 - copyrightFee;

        // Remove the token from the list of tokens for sale
        delete _sellers[tokenId];

        // Transfer the copyright fee to the specified recipient
        feeRecipient.transfer(copyrightFee); ///ETH不够会报错回退

        // Transfer the sale amount minus the copyright fee to the token owner
        tokenOwner.transfer(sellerGetFee);

        // Transfer ownership of the token to the buyer
        _transfer(tokenOwner, sender, tokenId);
        /// OR _safeTransfer(owner,sender,tokenId,"swap success");

        emit SawpInfo(tokenId, amount, tokenOwner,sender);
    }

///重写721QS中的`updateGuard`函数，当更新guard时，清除挂单信息

    function updateGuard(uint256 tokenId,address newGuard,bool allowNull) internal virtual override {

        address owner = ownerOf(tokenId); 

        address guard = guardOf(tokenId);
        if (!allowNull) {
            require(newGuard != address(0), "New guard can not be null");
        }
         if (guard != address(0)) { 
            require(guard == _msgSender(), "only guard can change it self"); 
        } else { 
            require(owner == _msgSender(), "only owner can set guard"); 
        } 

        if (guard != address(0) || newGuard != address(0)) {
            ///token_guard_map[tokenId]可视性为internal，能否在子合约中修改？
            token_guard_map[tokenId] = newGuard;
            ///设置guard时，清除挂单信息
            delete _sellers[tokenId];
            emit UpdateGuardLog(tokenId, newGuard, guard);
        }
    }
//-----}


/*
报价：买家对某个 NFT 的报价，可以理解为买家愿意为该 NFT 支付的价格。
接受：卖家对某个 NFT 收到的报价进行接受，同意将该 NFT 转移给买家。
那么，我们可以按照以下步骤来实现：

在合约中添加一个新的结构体 Offer 来存储报价信息。
在合约中添加一个映射 mapping (uint256 => mapping (address => Offer)) 来存储每个 NFT 的每个买家的报价信息。
在合约中添加一个新的函数 function makeOffer(uint256 tokenId, uint256 price) public 来实现买家报价的功能。
在合约中添加一个新的函数 function acceptOffer(uint256 tokenId, address buyer) public 来实现卖家接受报价的功能。
在合约中添加一个新的函数 function cancelOffer(uint256 tokenId, address buyer) public 来实现买家取消报价的功能。
*/

    struct Offer {
        uint256 price;   // NFT 价格
        uint64 expires;  // 报价过期时间，以 unix timestamp 表示
}
//为什么该映射不需要声明可见性或用internal
    mapping (uint256 => mapping (address => Offer))  _offers;

// 注意：这里需要使用 payable 关键字修饰函数，表示合约可以接收以太币
    function makeOffer(uint256 tokenId, uint256 price,uint64 expires) public payable {
    // 买家必须拥有足够的以太币来支付报价
    require(msg.value >= price, "Insufficient ether to make offer");

    // 将报价的 ETH 转移到合约地址
    address payable addresspayable = payable (address(this));

    addresspayable.transfer(price);

    // 记录报价信息
    _offers[tokenId][msg.sender] = Offer({
        price: price,
        expires: expires 
        });
    }
    //Offer.price = price;
    //offer.expries = expries;

    // 实现卖家接受报价的功能
    function acceptOffer(uint256 tokenId, address buyer) public payable{
    // 只有拥有 NFT 的卖家才能接受报价
        require(ownerOf(tokenId) == msg.sender, "Only the owner of the token can accept offers");

    // 检查报价是否存在
         Offer storage offer = _offers[tokenId][buyer];
        require(offer.price > 0, "Offer does not exist");

    // 检查报价是否过期
        require(offer.expires > block.timestamp, "Offer has expired");

    // 检查合约地址余额是否充足
        require(address(this).balance>=offer.price,"Not enough Ether in contract to complete the transfer");

    // 清除报价信息
        delete _offers[tokenId][buyer];

    // 接受报价并将 NFT 转移给买家
        _transfer(msg.sender, buyer, tokenId);
    // 卖家获得ETH
        address payable sender =payable(msg.sender);

        sender.transfer(offer.price);
    }

    // 实现买家取消报价的功能
    function cancelOffer(uint256 tokenId) public {
    // 检查报价是否存在
        Offer storage offer = _offers[tokenId][msg.sender];
        require(offer.price > 0, "Offer does not exist");
    // 清除报价信息
        delete _offers[tokenId][msg.sender];
    // 清除报价信息
    }
}

