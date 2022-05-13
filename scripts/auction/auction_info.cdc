// auction_status.cdc
// Gets auction status: nil = not started, true = ongoing, false = ended

import AuctionHouse  from 0x045a1763c93006ca

pub fun main(auction: Address, auctionID: UInt64): AuctionHouse.AuctionInfo? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionWalletPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(auctionID).auctionInfo()
}
