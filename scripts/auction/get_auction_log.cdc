// get_auction_log.cdc

import AuctionHouse_V16  from 0x045a1763c93006ca

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>
        (AuctionHouse_V16.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V16.Auction{AuctionHouse_V16.AuctionPublic}?
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
