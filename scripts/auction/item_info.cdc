// item_info.cdc
// Return item info of auction

import DAAM_V13          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V3  from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): DAAM_V13.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V3.AuctionWallet{AuctionHouse_V3.AuctionWalletPublic}>
        (AuctionHouse_V3.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V3.Auction{AuctionHouse_V3.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}