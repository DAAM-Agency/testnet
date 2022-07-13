// get_auction_log.cdc

import AuctionHouse_V10  from 0x01837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V10.AuctionWallet{AuctionHouse_V10.AuctionWalletPublic}>
        (AuctionHouse_V10.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V10.Auction{AuctionHouse_V10.AuctionPublic}?
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
