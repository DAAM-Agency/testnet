// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_V12 from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): [AnyStruct]
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V12.AuctionWallet{AuctionHouse_V12.AuctionWalletPublic}>(AuctionHouse_V12.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V12.Auction{AuctionHouse_V12.AuctionPublic}?
    let auctionHolder  = mRef!.auctionInfo()
    let metadataHolder = mRef!.itemInfo()

    return [auctionHolder, metadataHolder]
}