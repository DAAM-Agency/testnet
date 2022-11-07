// get_auctions.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_Mainnet  from 0x045a1763c93006ca

pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
        (AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!
    
    return auctionHouse.getAuctions()
}