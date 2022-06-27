// auction_status.cdc
// Gets auction status: nil = not started, true = ongoing, false = ended

import AuctionHouse_V6  from 0x01837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): Bool? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V6.AuctionWallet{AuctionHouse_V6.AuctionWalletPublic}>
        (AuctionHouse_V6.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V6.Auction{AuctionHouse_V6.AuctionPublic}?
    return mRef!.getStatus()
}
