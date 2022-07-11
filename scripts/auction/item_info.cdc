// item_info.cdc
// Return item info of auction

import DAAM_V18          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V9  from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): DAAM_V18.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V9.AuctionWallet{AuctionHouse_V9.AuctionWalletPublic}>
        (AuctionHouse_V9.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V9.Auction{AuctionHouse_V9.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}