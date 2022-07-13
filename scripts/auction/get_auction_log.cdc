// get_auction_log.cdc

import AuctionHouse_V11  from 0x01837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V11.AuctionWallet{AuctionHouse_V11.AuctionWalletPublic}>
        (AuctionHouse_V11.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V11.Auction{AuctionHouse_V11.AuctionPublic}?
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
