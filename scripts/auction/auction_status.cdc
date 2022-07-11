// auction_status.cdc
// Gets auction status: nil = not started, true = ongoing, false = ended

import AuctionHouse_V9  from 0x01837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): Bool? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V9.AuctionWallet{AuctionHouse_V9.AuctionWalletPublic}>
        (AuctionHouse_V9.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V9.Auction{AuctionHouse_V9.AuctionPublic}?
    return mRef!.getStatus()
}
