// get_auction_log.cdc

<<<<<<< HEAD
import AuctionHouse_V4  from 0x1837e15023c9249

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
        (AuctionHouse_V4.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V4.Auction{AuctionHouse_V4.AuctionPublic}?
=======
import AuctionHouse_V5  from 0x045a1763c93006ca

pub fun main(auction: Address, auctionID: UInt64): {Address:UFix64}? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
        (AuctionHouse_V5.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(auctionID) as &AuctionHouse_V5.Auction{AuctionHouse_V5.AuctionPublic}?
>>>>>>> DAAM_V15
    let metadata = mRef!.getAuctionLog()
    
    return metadata
}
