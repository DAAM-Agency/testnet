// get_auctions.cdc
// Return all auctions in Auction Wallet. Identified by TokenIDs

import AuctionHouse_V2 from 0x1837e15023c9249


pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
        .borrow()!

    return auctionHouse.getAuctions()
}