// item_info.cdc
// Return item info of auction

import DAAM_Mainnet          from 0xfd43f9148d4b725d
import AuctionHouse_Mainnet  from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): DAAM_Mainnet.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
        (AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_Mainnet.Auction{AuctionHouse_Mainnet.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}