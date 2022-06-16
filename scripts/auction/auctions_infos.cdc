// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM_V13         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V3 from 0x045a1763c93006ca

pub fun main(auction: Address): {UInt64 : DAAM_V13.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V3.AuctionWallet{AuctionHouse_V3.AuctionWalletPublic}>(AuctionHouse_V3.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM_V13.MetadataHolder?} = {}

    for aid in auctions {
        let mRef = auctionHouse.item(aid) as &AuctionHouse_V3.Auction{AuctionHouse_V3.AuctionPublic}?
        data.insert(key: aid, mRef!.itemInfo() )
    }
    return data
}