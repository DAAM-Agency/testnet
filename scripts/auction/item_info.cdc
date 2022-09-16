// item_info.cdc
// Return item info of auction

import DAAM_V23          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V16  from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): DAAM_V23.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>
        (AuctionHouse_V16.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V16.Auction{AuctionHouse_V16.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}