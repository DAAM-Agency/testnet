// buy_it_now_status.cdc
// Return is there is a Buy It Now option. If there is not or it expired, this will return false.

import AuctionHouse_V17 from 0x045a1763c93006ca

pub fun main(auction: Address, auctionID: UInt64): Bool {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V17.AuctionWallet{AuctionHouse_V17.AuctionWalletPublic}>
        (AuctionHouse_V17.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V17.Auction{AuctionHouse_V17.AuctionPublic}? 
    return mRef!.buyItNowStatus()
}
