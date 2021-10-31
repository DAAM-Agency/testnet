// item_info.cdc

import DAAM from 0xfd43f9148d4b725d
import AuctionHouse  from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): DAAM.Metadata? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!

    let metadata = auctionHouse.item(aid).itemInfo()

    return metadata
}