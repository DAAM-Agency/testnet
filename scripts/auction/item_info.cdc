// item_info.cdc
// Return item info of auction

import DAAM_V16          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V5  from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): DAAM_V16.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
        (AuctionHouse_V5.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V5.Auction{AuctionHouse_V5.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}