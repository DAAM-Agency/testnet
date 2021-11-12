// item_info.cdc
// REturn item info of auction

<<<<<<< HEAD
import DAAM_V5from 0xa4ad5ea5c0bd2fba
import AuctionHouse  from 0x045a1763c93006ca
=======
import DAAM_V5 from 0xa4ad5ea5c0bd2fba
import AuctionHouse  from 0x01837e15023c9249
>>>>>>> merge_dev

pub fun main(auction: Address, aid: UInt64): DAAM_V5.Metadata? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!

    let metadata = auctionHouse.item(aid).itemInfo()

    return metadata
}