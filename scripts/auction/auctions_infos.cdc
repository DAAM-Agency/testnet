// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM_V22         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V17 from 0x045a1763c93006ca

pub fun main(auction: Address): {UInt64 : DAAM_V22.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V17.AuctionWallet{AuctionHouse_V17.AuctionWalletPublic}>(AuctionHouse_V17.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM_V22.MetadataHolder?} = {}

    for aid in auctions {
        let mRef = auctionHouse.item(aid) as &AuctionHouse_V17.Auction{AuctionHouse_V17.AuctionPublic}?
        data.insert(key: aid, mRef!.itemInfo() )
    }
    return data
}