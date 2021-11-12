// auction_status.cdc
// Gets auction status: nil = not started, true = ongoing, false = ended

import AuctionHouse  from 0x01837e15023c9249

pub fun main(auction: Address, tokenID: UInt64): Bool? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(tokenID)!.getStatus()
}
