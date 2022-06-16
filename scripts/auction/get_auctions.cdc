// get_auctions.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V3  from 0x045a1763c93006ca

pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V3.AuctionWallet{AuctionHouse_V3.AuctionWalletPublic}>
        (AuctionHouse_V3.auctionPublicPath)
        .borrow()!
    
    return auctionHouse.getAuctions()
}