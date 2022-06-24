// get_auction_log.cdc

import AuctionHouse_V5  from 0x01837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
        (AuctionHouse_V5.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V5.Auction{AuctionHouse_V5.AuctionPublic}?
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
