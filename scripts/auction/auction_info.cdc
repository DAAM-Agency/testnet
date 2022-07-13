// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V11 from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): AuctionHouse_V11.AuctionHolder
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V11.AuctionWallet{AuctionHouse_V11.AuctionWalletPublic}>(AuctionHouse_V11.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V11.Auction{AuctionHouse_V11.AuctionPublic}?
    return mRef!.auctionInfo()
}