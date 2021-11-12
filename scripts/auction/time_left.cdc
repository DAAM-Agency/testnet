// time_left.cdc
// Return time left in auction

<<<<<<< HEAD
import AuctionHouse  from 0x045a1763c93006ca
=======
import AuctionHouse from 0x01837e15023c9249
>>>>>>> merge_dev

pub fun main(auction: Address, tokenID: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(tokenID)!.timeLeft()
}
