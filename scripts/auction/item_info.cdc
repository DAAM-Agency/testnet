// item_info.cdc
// Return item info of auction

import DAAM_V20          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V14  from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): DAAM_V20.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}>
        (AuctionHouse_V14.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V14.Auction{AuctionHouse_V14.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}