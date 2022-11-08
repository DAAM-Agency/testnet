// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_Mainnet from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): [AnyStruct]
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>(AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_Mainnet.Auction{AuctionHouse_Mainnet.AuctionPublic}?
    let auctionHolder  = mRef!.auctionInfo()
    let metadataHolder = mRef!.itemInfo()

    return [auctionHolder, metadataHolder]
}