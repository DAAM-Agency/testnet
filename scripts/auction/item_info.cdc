// item_info.cdc
// Return item info of auction

import DAAM_V10          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V2 from 0x1837e15023c9249

pub fun main(auction: Address, aid: UInt64): DAAM_V10.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
        .borrow()!

    let metadata = auctionHouse.item(aid).itemInfo()

    return metadata
}