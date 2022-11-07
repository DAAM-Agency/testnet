// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

import AuctionHouse_Mainnet from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): AuctionHouse_Mainnet.AuctionHolder
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>(AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_Mainnet.Auction{AuctionHouse_Mainnet.AuctionPublic}?
    return mRef!.auctionInfo()
}