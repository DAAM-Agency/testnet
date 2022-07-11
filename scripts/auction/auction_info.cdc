// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V9 from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): AuctionHouse_V9.AuctionHolder
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V9.AuctionWallet{AuctionHouse_V9.AuctionWalletPublic}>(AuctionHouse_V9.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V9.Auction{AuctionHouse_V9.AuctionPublic}?
    return mRef!.auctionInfo()
}