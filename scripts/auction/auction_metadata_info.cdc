// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V14 from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): [AnyStruct]
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}>(AuctionHouse_V14.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V14.Auction{AuctionHouse_V14.AuctionPublic}?
    let auctionHolder  = mRef!.auctionInfo()
    let metadataHolder = mRef!.itemInfo()

    return [auctionHolder, metadataHolder]
}