// auction_status.cdc
// Gets auction status: nil = not started, true = ongoing, false = ended

import AuctionHouse_V3  from 0x045a1763c93006ca

pub fun main(auction: Address, auctionID: UInt64): Bool? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V3.AuctionWallet{AuctionHouse_V3.AuctionWalletPublic}>
        (AuctionHouse_V3.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V3.Auction{AuctionHouse_V3.AuctionPublic}?
    return mRef!.getStatus()
}
