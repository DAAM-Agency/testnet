// get_auction_log.cdc

import AuctionHouse  from 0x1837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
        (AuctionHouse.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse.Auction{AuctionHouse.AuctionPublic}?
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
