# ERC721YY - No Intermediary NFT Trading Protocol

Dedicated to YY, hence the name 721YY.

Also known as: NFT trading protocol with global liquidity with 0 transaction fees.

## Summary

A one-sentence summary of the protocol: NFT trading functionality is written into NFT's own contracts, enabling NFT trading without relying on NFT trading intermediary platforms (e.g. OpenSea's seaport).

## Motivation

The vast majority of current NFT transactions rely on NFT trading platforms that act as intermediaries, such as OS, LR, X2, etc., which has the following problems.

1, security issues. For example, setApprovalForAll brings security problems. nft trading platform to obtain the permission to carry out unnecessary risk exposure, once the trading platform contract problems, will bring huge losses to the whole industry.

The function can authorize anyone to control the NFT, which was originally designed to allow third parties such as Rarible and OpenSea to control the NFT on behalf of the user, then multiple NFT transactions, only need to authorize once, the subsequent pending transactions through the signature to save gas fees. However, once the function is authorized, an attacker can transfer all NFTs in the victim's name to his or her account by using the transferFrom function on the contract. This function is very dangerous by design, and users are not always aware of what permissions they are giving by signing transactions. Most of the time, victims think these are just routine transactions.

In addition, if a user has authorized a certain category of their NFTs, in OpenSea, the latest phishing scam, which is based on signature technology, allows the victim to place an order at the OS at a very low price and designate the recipient, and then complete the transaction for undue profit. Ordinary users are defenseless against this.

2, high transaction costs and transaction fees, the increase in trading platforms has led to liquidity dispersion and increased transaction costs. With more trading platforms, NFT liquidity fragmentation. If there is only one NFT trading platform in the market, setApprovalForAll originally enhanced the efficiency of multiple NFT sell and save the need for multiple authorization of gas fees. But with the liquidity and trading volume distributed across multiple NFT trading platforms, if a user needs the fastest transaction, it is necessary to carry out multiple platform authorization and pending orders, which further increases the risk exposure, and each authorization requires gas fees. And BAYC, for example, the total number of 10,000, the number of holders of more than 6,000, the average number of NFT per person holding less than 2, setApprovalForAll save a single platform NFT pending order gas fee, but because of the need to authorize to multiple platforms, in essence, for the user, and lead to an increase in transaction gas fees. In addition, the transaction fees charged by the platform, should also be listed as the cost of the user transaction, which may even be much higher than the gas fee.

3, aggregators provide a solution for aggregating liquidity, but the decision of whether an aggregator aggregates the liquidity of a particular trading platform is centralized. And because the transaction information of the trading platform is under the chain, the efficiency of the aggregator to obtain the order data is affected by the trading platform api limit frequency (specify the frequency limit of the Dao surname OS on their own api and the restriction on issuance; X2Y2 on blur).

4, the project side copyright tax revenue obtained or not depends on the centralized decision of the trading platform, some trading platforms disregard the interests of the project side, the implementation of 0 copyright tax (naming X2Y2, sudoswap and Magic Eden), infringing on the interests of the project side. (Personally, I believe that project parties can be encouraged to moderately reduce copyright tax and adopt new copyright tax mechanisms, but it is not appropriate to be generous at the expense of others and directly abolish copyright tax).

Our research on the new copyright tax scheme.

https://mirror.xyz/5660.eth/ymqq1CB7ALJYZe5StLeqo11jl6VBH9ztbhqpFQNTK_E 

OS has already taken down many NFTs, and the rules for doing so are centralized and not transparent enough.

## Solution

In short, directly write the NFT transaction function into the NFT's own contract, and set up a mechanism for royalty distribution. This way we have no intermediary, more secure, 0 transaction fees, with network-wide liquidity and meet the project side of the copyright tax revenue, anti-censorship NFT trading protocol.

## Basic mechanism design

### Copyright tax

Copyright tax parameters, set by the NFT contract owner, can only be modified by the NFT contract owner.

Copyright tax parameters (tax rate, a%; copyright tax receiving address, Alice)

fee(fee, fee to), fee, the royalty rate; fee to, the royalty receiving address.

You can also use the ERC2981 copyright tax standard (if it is convenient to use). Copyright tax you project side if not, we are very short of money, but also encourage the project side to give us a reward tip, address fill 5660.eth anti-resolution address on the line.

### Transaction

Transaction price parameters, etc., set by the NFT holder.

Transaction parameters (token ID; transaction price, b; income receiving address, Bob; transaction period, expire)

Swap(token id; price; to ; expire)

price, the transaction price (ETH), any person who invokes the contract and pays that price to the contract eth, can get the NFT, price can not be 0.

to, transaction revenue receiving address, can not be NFT owner, if not set, the default is the owner address; transaction revenue price ?? (1-fee) to Bob address, royalty price ?? fee to the royalty receiving address Alice. (can be based on the discussion, to determine whether the need for this parameter, if not the parameter, the default will be revenue to owner address)

expire, period, the price valid period, beyond the time expire. If not set, that is, the default infinite length.

When the NFT holder enters the transaction price, transaction address, transaction period, the order is visible to the entire network.

When the NFT transfer occurs, that is, clear the transaction information.

Set clear pending order function. remove swap, the user can call the contract to clear pending order information.

Currently only consider the transaction currency is ETH, such as the need to introduce ERC20 or more complex ERC721, etc., need to be further designed.

Note: Consider the issue of compatibility with 721qs. Set the condition that swap can be set only when there is no guard, if there is swap, swap information will be cleared when setting the guard.

### Example of use

1, NFT contract owner set the royalty tax rate of 1%, the royalty receiving address for Alice;

2, Bob mint the NFT#0001.

3, Bob call the NFT contract, set the parameters: sell NFT#0001 at 5ETH within 3 days and transfer the proceeds to Cindy.

4, 5660.eth like NFT#0001, willing to buy NFT#0001 at 5ETH, D call the NFT contract, spend 5ETH to buy the NFT

At this point, NFT#0001 from Bob's address to 5660.eth address; royalty 0.05e to Alice's address; 4.95e to Cindy's address. The transaction is complete.

### Design advantages

1, peer-to-peer transactions, no set approval for all, more secure transactions.

2, 0 transaction fees.

3, NFT transaction pending list information can be seen throughout the network, any user who pays the corresponding price can access the NFT, any platform that supports NFT view, can access all the pending list information of the NFT series and can be traded, achieving market-wide liquidity aggregation; aggregation trading platform is also free from the api frequency limit.

4, the project side copyright tax revenue is protected.

Through the setting, NFT contract comes with a trading function, all NFT platform can call NFT contract information, query NFT pending orders, to achieve global liquidity aggregation, save gas fees and achieve 0 transaction fees, to ensure that the project side of the royalty rights and interests are not compromised.

## Viewpoint

The current 721 protocol is extremely rudimentary, it can barely adapt to the future development of the NFT world, we need to improve it. 721QS provides another role in addition to the owner, the guard, to improve the protocol use scenario corresponding to the role of different asset relationships required. And although we can implement NFT transactions through the trading platform, in essence 721 does not have a transaction function, only transfer, not swap, which is why the copyright tax is not enforceable and NFT transactions require an intermediary platform, 721YY complements the underlying protocol support needed in its transaction scenario. These extensions at the protocol level are extremely simple.

The blockchain world has a saying "fat protocols, thin applications", and while we don't intend to support that view, we do mindlessly support it by refining the protocol.

NFT is a completely different asset than FT, and many people don't really understand the meaning of this phrase. This means that the resulting direction of value capture may be completely different, for example, in the FT space, CEX earns huge revenues through transaction fees, while in the NFT space, as it stands, it is almost difficult for traditional CEX to enter this market, although DEX such as OpenSea earns good revenues through transaction fees, but through 721YY, NFT trading requires almost no any trading intermediary, there are 0 transaction fees, and no platform can go through the transaction fees to capture the huge value.

NFT project owners can consider using this protocol in conjunction with contract blacklisting, for example, to restrict their NFTs from trading on platforms that do not charge royalties, and similarly, since 0 transaction fees have been achieved using this protocol, project owners can also consider restricting NFTs from trading on platforms that charge excessive transaction platforms that charge excessive transaction fees.
Questions to ponder

It is worth thinking about how, with a similar agreement to 721YY, after a few years have passed, NFT trading platforms, and the need for them to exist, will still be alive and well, and what is the reason for their existence.

## Q & A

Q: So where should the NFT trading platform go?

A: The agreement changes the current profit model of all trading platforms, trading platforms can focus on improving the level of service in order to collect service fees.

For example, NFT-AMMs, which provides instant liquidity, LPs capture the value of the service fee for providing liquidity rather than transaction fees.

Our study of NFT-AMMs, and the proposed model

https://mirror.xyz/5660.eth/C-dILZBAtZz5D4lSJi-DiJ7oy6ToOkYVolF26NibwiQ 

Q: The current mainstream NFT platform is optimizing gas, this solution may be more gas-consuming?

A: Leaving aside the advantages of other aspects, for users, the transaction fees paid are also part of their overall costs. If the transaction fee is also calculated as the cost of users, the comparison between the two solutions will be higher and lower. In addition, this solution has a stronger advantage over other low GAS fee public chains.

Q: How can the offer function be implemented?

A: It can be implemented, but it will be more complicated, but we do not want to implement such a complex function in ERC721 protocol layer for the time being, and it seems to be impossible to avoid setApprovalForAll for the time being. another perspective, the other way around, the offer is actually the pending order of ETH or ERC20 tokens, so the subsequent may need to improve the ERC20 protocol.

Q: How to understand transfer and swap

A: transfer is equivalent to swap with specified address and 0 price. swap mechanism is designed to be compatible with the transfer function, but it is not considered for the time being in order to be compatible with the current ERC721 application.

Any comments and suggestions, welcome to get in touch with CR

Twitter: https://twitter.com/web3saltman

E-mail: 5660@10kuni.io

Information aggregation: https://5660.eth.limo 

