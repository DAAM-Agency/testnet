// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V8 from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): AuctionHouse_V8.AuctionHolder
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V8.AuctionWallet{AuctionHouse_V8.AuctionWalletPublic}>(AuctionHouse_V8.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V8.Auction{AuctionHouse_V8.AuctionPublic}?
    return mRef!.auctionInfo()
}