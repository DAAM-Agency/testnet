// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM_V19         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V12 from 0x045a1763c93006ca

pub fun main(auction: Address): {UInt64 : DAAM_V19.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V12.AuctionWallet{AuctionHouse_V12.AuctionWalletPublic}>(AuctionHouse_V12.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM_V19.MetadataHolder?} = {}

    for aid in auctions {
        let mRef = auctionHouse.item(aid) as &AuctionHouse_V12.Auction{AuctionHouse_V12.AuctionPublic}?
        data.insert(key: aid, mRef!.itemInfo() )
    }
    return data
}