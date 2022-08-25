// item_info.cdc
// Return item info of auction

import DAAM_V23          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V15  from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): DAAM_V23.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V15.AuctionWallet{AuctionHouse_V15.AuctionWalletPublic}>
        (AuctionHouse_V15.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V15.Auction{AuctionHouse_V15.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}