// buy_it_now_status.cdc
// Return is there is a Buy It Now option. If there is not or it expired, this will return false.

import AuctionHouse_V11 from 0x01837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): Bool {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V11.AuctionWallet{AuctionHouse_V11.AuctionWalletPublic}>
        (AuctionHouse_V11.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V11.Auction{AuctionHouse_V11.AuctionPublic}? 
    return mRef!.buyItNowStatus()
}
