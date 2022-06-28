// item_info.cdc
// Return item info of auction

import DAAM_V18          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V8  from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): DAAM_V18.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V8.AuctionWallet{AuctionHouse_V8.AuctionWalletPublic}>
        (AuctionHouse_V8.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V8.Auction{AuctionHouse_V8.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}