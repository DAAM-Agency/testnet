// auction_info.cdc
// Return auction info in Auction Wallet. Identified by AuctionIDs

<<<<<<< HEAD
import AuctionHouse_V5 from 0x045a1763c93006ca
=======
import AuctionHouse_V4 from 0x1837e15023c9249
>>>>>>> bd81b241c4ac2c6110b14f47632daf3e3af02f31

pub fun main(auction: Address, aid: UInt64): [AnyStruct]
{    
    let auctionHouse = getAccount(auction)
<<<<<<< HEAD
        .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>(AuctionHouse_V5.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V5.Auction{AuctionHouse_V5.AuctionPublic}?
=======
        .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>(AuctionHouse_V4.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V4.Auction{AuctionHouse_V4.AuctionPublic}?
>>>>>>> bd81b241c4ac2c6110b14f47632daf3e3af02f31
    let auctionHolder  = mRef!.auctionInfo()
    let metadataHolder = mRef!.itemInfo()

    return [auctionHolder, metadataHolder]
}