// item_info.cdc
// Return item info of auction

import DAAM_V21          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V14  from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): DAAM_V21.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}>
        (AuctionHouse_V14.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V14.Auction{AuctionHouse_V14.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}