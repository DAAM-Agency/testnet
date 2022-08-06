// buy_it_now_status.cdc
// Return is there is a Buy It Now option. If there is not or it expired, this will return false.

import AuctionHouse_V14 from 0x01837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): Bool {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}>
        (AuctionHouse_V14.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V14.Auction{AuctionHouse_V14.AuctionPublic}? 
    return mRef!.buyItNowStatus()
}
