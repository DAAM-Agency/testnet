// get_auctions.cdc
// Return all auctions in Auction Wallet. Identified by TokenIDs

import AuctionHouse  from 0x01837e15023c9249


pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!

    return auctionHouse.getAuctions()
}