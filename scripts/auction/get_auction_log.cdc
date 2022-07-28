// get_auction_log.cdc

import AuctionHouse_V14  from 0x045a1763c93006ca

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}>
        (AuctionHouse_V14.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V14.Auction{AuctionHouse_V14.AuctionPublic}?
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
