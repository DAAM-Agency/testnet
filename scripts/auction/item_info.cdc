// item_info.cdc
// Return item info of auction

import DAAM_V8          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V2 from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): DAAM_V8.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
        .borrow()!

    let metadata = auctionHouse.item(aid).itemInfo()

    return metadata
}