// item_info.cdc
// Return item info of auction

import DAAM_V17          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V7  from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): DAAM_V17.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V7.AuctionWallet{AuctionHouse_V7.AuctionWalletPublic}>
        (AuctionHouse_V7.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V7.Auction{AuctionHouse_V7.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}