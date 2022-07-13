// auction_status.cdc
// Gets auction status: nil = not started, true = ongoing, false = ended

import AuctionHouse_V10  from 0x01837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): Bool? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V10.AuctionWallet{AuctionHouse_V10.AuctionWalletPublic}>
        (AuctionHouse_V10.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V10.Auction{AuctionHouse_V10.AuctionPublic}?
    return mRef!.getStatus()
}
