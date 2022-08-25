// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V17 from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): AuctionHouse_V17.AuctionHolder
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V17.AuctionWallet{AuctionHouse_V17.AuctionWalletPublic}>(AuctionHouse_V17.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V17.Auction{AuctionHouse_V17.AuctionPublic}?
    return mRef!.auctionInfo()
}