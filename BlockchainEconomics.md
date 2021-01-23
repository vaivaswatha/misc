# The Economics of Blockchain

## What prompted me to write this
I came across this [Twitter thread](https://twitter.com/smdiehl/status/1350869944888664064), which I agree with on some aspects, but found to be
incomplete w.r.t a more general aspect of blockchains: **Smart Contracts**.
But before I go into that, I'll start by addressing a few points made
about Bitcoin in the Twitter thread.

> Let's discuss the environmental cost of bitcoin.

I agree about the environmental impacts of bitcoin mining. This is
however not true of all blockchains. Not all of them rely on
proof-of-work for mining every block.

>It's a pyramid-shaped investment scheme backed by the collective delusion that value can created out of nothing by convincing greater fools to buy it after you do. ... Unlike other economic activities, the bitcoin scheme produces absolutely nothing for all this waste. It is a pure speculative activity of people gambling on the random movements of prices and the only output is simply shuffling numbers around in a computer at insane cost.

While I agree that this is how it seems to be working in practice, it
isn't fundamentally what Bitcoin is. A good analogy that illustrates my point is the market value of gold today. Apart from uses of gold due to its
chemically inert properties, it has no [intrinsic value](https://www.investopedia.com/articles/investing/071114/why-gold-has-always-had-value.asp).
Gold is valued highly today primarily because of its limited supply
throughout history. It isn't too rare (making it impractical to use as
currency / for trading) nor is it too abundant (making it less valuable).
Gold has the value it has, because we have all agreed to give it that value.
Bitcoin is better seen from this perspective. A currency that is limited
in its supply, available for use in trading, with no central authority
controlling its price. So if Bitcoin is to be seen as a "purely speculative
activity of people gambling", the same can (I guess) be said about gold
too, igoring its intrinsic value (which is far below its market value).

## Decentralized Systems Prior to Bitcoin Popularity
Peer-to-peer networks, such as [BitTorrent](https://en.wikipedia.org/wiki/BitTorrent)
have been popular much before Bitcoin beacme popular.
However, it was hard to enforce rules (of any kind) on these networks.
For example, while someone who had a copy of a file would `seed` it,
to share among others, and there was a moral obligation for the
person downloading it to re-share it, it was hard to mandate `seeding`.
People could just `leech` of `seeders`, being a bad member of the community,
without having to pay any kind of penalty.

Suppose we want to mandate compensation of seeders for their bandwidth / power costs.
With a central authority, the problem could be simpler to solve, with the money paid
from the leecher to the seeder upon completion of a download. In a decentralized network,
this is a harder problem. The network, as a whole, must monitor that data indeed was
transferred from the seeder to the leecher's computer, and then, the leecher's money
(to which the network must have access to already) transferred to the seeder.

## Smart Contracts
Suppose you could write a program, which is an entity in itself, to which
money could be sent from the leecher, as a collateral. The seeder submits "proof"
of having shared the file to this program. If the proof is valid, the program
sends the money to the seeder. We do not dwelve into the details of how such a proof
can be designed in this article.

All we need now is a decentralized enforcer of this program's rules. That's exactly
what a blockchain is, and the program: a smart contract. A blockchain protocol ensures
that all the nodes in that network together arrive at a consensus over a transaction.

## The Concept of Money or Tokens
The nodes (computers) on the blockchain network perform computations inorder to arrive
at a consensus on the transactions (say the execution of a smart contract). Just like
in our example, a torrent seeder needed to be paid, these node operators need to be paid
for carrying out computations on behalf of the entire network. Tokens such as ETH or ZILs
are the currency in which they are paid. This is commonly referred to as "gas" in the
blockchain world. As a blockchain network gains popularity, more smart contracts are
deployed on it with a wider application spectrum. A higher demand on the network leads
to higher costs of executing your smart-contract. The cryptocurrency now has a higher
**intrinsic value**. It isn't just something that people attach a value to, anymore.
It can be used to run computations on the network, a decentralized network with node
operators paid to perform computations.

So while it looks like, as the Twitter thread pointed out, a pyramid scheme where people
bet on other people buying your invement for a higher value, it isn't really so. At least
not on smart-contract enabled blockchains.

On a closing note, while there are a lot of "made up" applications of blockchains
(which are probably better of carried out on a traditional centralized model), there are
few applications that cannot be done without blockchains. 

A few that come to mind:

  1. A decentralized BitTorrent like file-sharing network where seeders are actually paid
  for their bandwidth and electricity.
  2. A decentralized social network (like Twitter, for example) where users can post
  publicly, for free, and advertisers can pay for the network cost. All of this can
  be transparent, with the bonus advantage of being immune to censorship. We already
  have a step in this direction, [Unstoppable Domains](https://unstoppabledomains.com/).

These applications are currently not very practical on popular blockchains such as Ethereum,
mostly because of the high computation costs in arriving at a consensus. I'm hoping that
more modern blockchain networks, such as Zilliqa (the company that I currently work for),
will bring these applications to a practical, usable reality.
