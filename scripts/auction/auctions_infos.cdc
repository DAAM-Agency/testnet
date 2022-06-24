// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM_V15         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V5 from 0x01837e15023c9249

pub fun main(auction: Address): {UInt64 : DAAM_V15.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>(AuctionHouse_V5.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM_V15.MetadataHolder?} = {}

    for aid in auctions {
        let mRef = auctionHouse.item(aid) as &AuctionHouse_V5.Auction{AuctionHouse_V5.AuctionPublic}?
        data.insert(key: aid, mRef!.itemInfo() )
    }
    return data
}