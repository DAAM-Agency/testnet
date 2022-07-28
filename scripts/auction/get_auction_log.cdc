// get_auction_log.cdc

import AuctionHouse_V12  from 0x045a1763c93006ca

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V12.AuctionWallet{AuctionHouse_V12.AuctionWalletPublic}>
        (AuctionHouse_V12.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V12.Auction{AuctionHouse_V12.AuctionPublic}?
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
