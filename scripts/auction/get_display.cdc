// get_display.cdc
// Return the MetadataViews of an Auction.

import MetadataViews         from 0x631e88ae7f1d7c20
import AuctionHouse_Mainnet  from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): {String: MetadataViews.Media} {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
        (AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_Mainnet.Auction{AuctionHouse_Mainnet.AuctionPublic}?
    let metadata = mRef!.getDisplay()

    return metadata
}