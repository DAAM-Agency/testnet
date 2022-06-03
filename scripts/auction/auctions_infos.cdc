// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM_V11         from 0xfd43f9148d4b725d
import AuctionHouse from 0x045a1763c93006ca

pub fun main(auction: Address): {UInt64 : DAAM_V11.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM_V11.MetadataHolder?} = {}

    for aid in auctions {
        let mRef = auctionHouse.item(aid) as &AuctionHouse.Auction{AuctionHouse.AuctionPublic}?
        data.insert(key: aid, mRef!.itemInfo() )
    }
    return data
}