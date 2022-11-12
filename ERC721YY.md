# ERC721YY-无中介NFT交易协议

献给YY，故起名721YY。

又名：0交易手续费的具有全局流动性的NFT交易协议。

## 摘要

一句话总结该协议：将NFT交易功能写入NFT自身合约，实现不依赖于NFT交易中介平台（例如OpenSea的seaport）的NFT交易。

## 动机

当前NFT的交易绝大部分依赖充当中介的NFT交易平台，如OS、LR、X2等，这存在以下问题。

1，安全问题。例如，setApprovalForAll带来的安全性问题。NFT交易平台获取的该权限，进行了不必要风险暴露，一旦交易平台合约出现问题，将对全行业带来巨大损失。
该函数可以授权任何人控制 NFT，其设计初衷是为了让 Rarible 和 OpenSea 等第三方能够代表用户控制 NFT，那么多个NFT交易，仅需要授权一次，后续通过签名挂单交易即可节省gas费用。但一旦该函数完成授权，攻击者就可以通过使用合约上的 transferFrom 函数将受害者名下的所有 NFT 转移到自己的账户。该功能在设计上非常危险，用户并不总是清楚他们通过签署交易给予了哪些权限。大多数时候，受害者认为这些仅为常规交易。

此外，如果用户对自己某个类别的NFT，在OpenSea进行了授权，最新的钓鱼网站诈骗，是通过签名技术，让受害者在OS以极低价格挂单，并指定接收者，然后完成交易，从而获取不当利益。普通用户对此防不胜防。

2，交易费用和交易手续费高，交易平台增多导致了流动性分散和交易成本提升。随着交易平台增多，NFT流动性分散。假如市场上只有一个NFT交易平台，setApprovalForAll原本提升了多个NFT卖出时的效率和节省了多次授权需要的gas费用。但随着流动性和交易量分布在多个NFT交易平台，如果一个用户需要最快成交，则需要进行多平台授权和挂单，这更进一步增大了风险暴露，且每次授权都需要gas费。而以BAYC为例，总量10000个，持有人数超过6000个，平均每人持有NFT数量不足2个，setApprovalForAll节省了单个平台的NFT挂单gas费，但由于需要授权给多平台，实质上对用户而言，又导致交易gas费用的增加。此外，平台所收取的交易手续费，也应当列为用户交易的成本，这部分成本甚至可能远远高于gas费。

3，聚合器提供了一种聚合流动性的方案，但聚合器是否聚合某个交易平台的流动性，其决策是中心化的。且由于交易平台的交易信息是在链下，聚合器获取订单数据的效率受到交易平台api限频的影响（指明道姓OS对自己api的限频以及限制发放；X2Y2对blur的限制)。

4，项目方版权税收入取得与否依赖于交易平台的中心化决策，部分交易平台不顾项目方利益，推行0版权税(指名道姓X2Y2，sudoswap和Magic Eden)，侵害了项目方利益。（个人认为，可以鼓励项目方适度降低版权税，和采用新的版权税机制，但不宜慷他人之慨，直接取消版权税）。

我们对新版权税方案的研究：

https://mirror.xyz/5660.eth/ymqq1CB7ALJYZe5StLeqo11jl6VBH9ztbhqpFQNTK_E 

5，不抗审查。OS已经下架了诸多NFT，下架规则的制定和执行是中心化的且不够透明。

## 解决方案

简而言之，直接将NFT交易功能写入NFT自身合约，并设定好版权费分配机制。这样我们就有了无中介的、更加安全的、0交易手续费的、具有全网流动性且满足项目方版权税收入、抗审查的NFT交易协议。

## 基本机制设计

### 版权税

版权税参数，由NFT合约所有者设置，仅有NFT合约所有者可以修改。

版权税参数(税率，a%；版权税接收地址，Alice)

fee(fee, fee to)，fee，版权费比率；fee to，版权税接收地址。

也可以采用ERC2981版权税标准(假如用起来方便)。版权税你们项目方要是不要，我们倒是很缺钱，也鼓励项目方给我们打赏小费，地址填5660.eth反解析地址就行。

### 交易

交易价格参数等，由NFT持有者设置。

交易参数（token ID；交易价格，b；收入接收地址，Bob；交易期限，expire）

Swap(token id；price；to ; expire)

price，交易价格（ETH），任意一人调用合约并向合约支付该价格的eth，都可以获得该NFT，price不能为0。

to，交易收入接收地址，可以不为NFT owner，如果不设置，默认为owner地址;交易收入price×(1-fee)转至Bob地址，版权费price×fee转给版权税接收地址Alice。（可以根据讨论，确定是否需要该参数，若无该参数，则默认将收入转至owner地址）

expire，期限，价格有效期间，超出时间失效。如果不设置，即默认无限长。

当NFT持有者输入交易价格，交易地址，交易期限，该订单即全网可见。

当NFT发生转移时，即清除交易信息。

设置清除挂单功能。remove swap，用户可以调用合约，清除挂单信息。

当前仅考虑交易币种为ETH，如需要引入ERC20或更复杂的ERC721等,需要进一步设计。

注意：考虑与721qs兼容问题。设置条件，只有在没有guard的时候，可以设置swap，如果已有swap，设置guard时即清除swap信息。

### 使用示例

1，	NFT合约所有者设置版权税税率1%，版权税接收地址为Alice;

2，	Bob mint该NFT#0001；

3，	Bob调用NFT合约，设置参数：在3天内以5ETH价格卖出NFT#0001，并将收入转给Cindy；

4，	5660.eth喜欢NFT#0001，愿意以5ETH价格买入NFT#0001,D调用NFT合约，花费5ETH买入该NFT

此时，NFT#0001从Bob地址转至5660.eth地址；版权税0.05e转至Alice地址；4.95e转至Cindy地址。交易完成。

### 设计优点

1，点对点交易，无需set approval for all，交易更加安全；

2，0交易手续费；

3，NFT交易挂单信息全网均可以看到，任何支付相应价格的用户都能获取该NFT，任何支持NFT查看的平台，都可以获取该NFT系列的所有挂单信息且可以交易，实现了全市场流动性聚合；聚合交易平台也免受api限频的影响；

4，项目方版权税收入得到保障。

通过该设置，NFT合约自带交易功能，所有NFT平台都可以调用NFT合约信息，查询NFT挂单情况，实现了全局流动性聚合，节约了gas费和实现了0交易手续费，保证了项目方的版权费权益不受损害。

## 观点

当前721协议极其简陋，它几乎不能适应未来NFT世界的发展，我们需要完善它。721QS提供了除owner的另外一个角色，guard，完善了协议使用场景中对应不同资产关系所需要的角色关系。而尽管我们能通过交易平台实现NFT的交易，但实质上721不存在交易功能，只有transfer，没有swap，这是为什么版权税无法强制执行，且NFT交易需要中介平台的原因，721YY则补足了其交易场景中所需的底层协议支持。而这些在协议层的扩展，都是极其简洁的。

区块链世界有“胖协议，瘦应用”的说法，尽管我们无意支持该观点，但我们确实通过对协议的完善，无心佐证了这句话。

NFT是完全不同于FT的资产，很多人并不真正理解这句话的含义，行业的思维惯性太重了。这意味着由此诞生的价值捕获方向，可能是完全不同的，例如，在FT领域，CEX通过交易手续费获取了巨大收入，而在NFT领域，就现状而言，传统CEX几乎很难进入这个市场，虽然OpenSea等DEX通过交易手续费赚取了不错的收入，但通过721YY，NFT交易几乎不需要任何交易中介，是0交易手续费的，也没有平台能通过交易手续费去捕获巨大价值。

通过该协议，让收取费用的权力最终都回归到项目方手里。NFT项目方可以考虑将该协议和合约黑名单功能一起使用，比如，NFT项目方可以限制自己的NFT在不收取版权税的平台交易，同样，由于使用本协议已经实现了0交易手续费，项目方同样也可以考虑限制NFT在收取过高交易手续费的平台交易。
值得思考的问题

可以思考一下，有了721YY类似协议，几年过去之后，NFT交易平台，还有存在的必要，还能活下来吗，需要他们存在的理由是什么。

## Q&A

问：如此这般，NFT交易平台该走向何方？

答：该协议改变了当前所有交易平台盈利模式，交易平台可以集中于提高服务水平以收取服务费用。

比如NFT-AMMs，它提供了即时流动性，LP捕获的价值，与其说是交易手续费，不如说是提供流动性的服务费用。
我们对NFT-AMMs的研究，以及提出的模型

https://mirror.xyz/5660.eth/C-dILZBAtZz5D4lSJi-DiJ7oy6ToOkYVolF26NibwiQ 

问：目前主流NFT平台在优化gas，这种方案可能更耗gas？

答：姑且不谈其他方面的优势，对用户来讲，支付的交易手续费也是其综合成本的一部分。如果把交易手续费也作为用户成本去计算的话，两种方案的对比就高下立判了。此外，该方案在其他低GAS费公链具有更强大的优势。

问：offer功能如何实现？

答：可以实现，但会复杂一些，但我们暂时不想在ERC721协议层实现这么复杂的功能，且似乎暂时无法避开setApprovalForAll。另一个视角，反过来理解，offer其实是ETH或ERC20代币的挂单，所以后续可能需要完善的是ERC20协议。

有任何意见和建议，欢迎和CR取得联系

推特：https://twitter.com/web3saltman

邮箱：5660@10kuni.io

信息聚合：https://5660.eth.limo 