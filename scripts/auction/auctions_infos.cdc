// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM_V10        from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V2 from 0x1837e15023c9249

pub fun main(auction: Address): {UInt64 : DAAM_V10.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM_V10.MetadataHolder?} = {}

    for aid in auctions {
        data.insert(key: aid, auctionHouse.item(aid).itemInfo() )
    }
    return data
}