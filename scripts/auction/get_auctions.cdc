// get_auctions.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V4  from 0x045a1763c93006ca

pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
        (AuctionHouse_V4.auctionPublicPath)
        .borrow()!
    
    return auctionHouse.getAuctions()
}