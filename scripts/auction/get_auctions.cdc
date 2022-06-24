// get_auctions.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

<<<<<<< HEAD
import AuctionHouse_V4  from 0x1837e15023c9249

pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
        (AuctionHouse_V4.auctionPublicPath)
=======
import AuctionHouse_V5  from 0x045a1763c93006ca

pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
        (AuctionHouse_V5.auctionPublicPath)
>>>>>>> DAAM_V15
        .borrow()!
    
    return auctionHouse.getAuctions()
}