// item_info.cdc
// Return item info of auction

import DAAM_V23          from 0xa4ad5ea5c0bd2fba
import AuctionHouse  from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): DAAM_V23.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
        (AuctionHouse.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse.Auction{AuctionHouse.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}