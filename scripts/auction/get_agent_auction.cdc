// get_agent_auctions.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V16  from 0x045a1763c93006ca

pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>
        (AuctionHouse_V16.auctionPublicPath)
        .borrow()!
    
    return auctionHouse.getAgentAuctions()
}