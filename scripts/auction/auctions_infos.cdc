// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM         from 0xfd43f9148d4b725d
import AuctionHouse from 0x045a1763c93006ca

pub fun main(auction: Address): {UInt64 : DAAM.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM.MetadataHolder?} = {}

    for aid in auctions {
        data.insert(key: aid, auctionHouse.item(aid).itemInfo() )
    }
    return data
}