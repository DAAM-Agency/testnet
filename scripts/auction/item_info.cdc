// item_info.cdc
// Return item info of auction

import DAAM_V14          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V4  from 0x1837e15023c9249

pub fun main(auction: Address, aid: UInt64): DAAM_V14.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
        (AuctionHouse_V4.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V4.Auction{AuctionHouse_V4.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}