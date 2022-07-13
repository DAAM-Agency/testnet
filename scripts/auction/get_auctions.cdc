// get_auctions.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V11  from 0x01837e15023c9249

pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V11.AuctionWallet{AuctionHouse_V11.AuctionWalletPublic}>
        (AuctionHouse_V11.auctionPublicPath)
        .borrow()!
    
    return auctionHouse.getAuctions()
}