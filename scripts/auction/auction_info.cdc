// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V15 from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): AuctionHouse_V15.AuctionHolder
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V15.AuctionWallet{AuctionHouse_V15.AuctionWalletPublic}>(AuctionHouse_V15.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V15.Auction{AuctionHouse_V15.AuctionPublic}?
    return mRef!.auctionInfo()
}