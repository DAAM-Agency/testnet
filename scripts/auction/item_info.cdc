// item_info.cdc
// Return item info of auction

<<<<<<< HEAD
import DAAM_V10          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V2 from 0x1837e15023c9249

pub fun main(auction: Address, aid: UInt64): DAAM_V10.MetadataHolder? {    
=======
import DAAM_V14          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V4  from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): DAAM_V14.MetadataHolder? {    
>>>>>>> DAAM_V14
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
        (AuctionHouse_V4.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V4.Auction{AuctionHouse_V4.AuctionPublic}?
    let metadata = mRef!.itemInfo()

    return metadata
}