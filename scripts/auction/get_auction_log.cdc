// get_auction_log.cdc

import AuctionHouse_V4  from 0x1837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
        (AuctionHouse_V4.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V4.Auction{AuctionHouse_V4.AuctionPublic}?
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
