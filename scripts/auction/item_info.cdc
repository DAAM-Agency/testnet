// item_info.cdc
// Return item info of auction

import DAAM_Mainnet          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet  from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): DAAM_Mainnet.MetadataHolder? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
        (AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_Mainnet.Auction{AuctionHouse_Mainnet.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}