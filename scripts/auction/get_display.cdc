// get_display.cdc
// Return the MetadataViews of an Auction.

import DAAM          from 0xfd43f9148d4b725d
import AuctionHouse  from 0x045a1763c93006ca
import MetadataViews from 0xf8d6e0586b0a20c7

pub fun main(auction: Address, aid: UInt64): {String: MetadataViews.Media} {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
        (AuctionHouse.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse.Auction{AuctionHouse.AuctionPublic}?
    //let metadata = mRef!.itemInfo().
    let metadata = mRef!.getDisplay() 

    return metadata
}