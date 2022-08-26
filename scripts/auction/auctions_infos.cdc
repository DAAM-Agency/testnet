// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM_V23         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V16 from 0x01837e15023c9249

pub fun main(auction: Address): {UInt64 : DAAM_V23.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>(AuctionHouse_V16.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM_V23.MetadataHolder?} = {}

    for aid in auctions {
        let mRef = auctionHouse.item(aid) as &AuctionHouse_V16.Auction{AuctionHouse_V16.AuctionPublic}?
        data.insert(key: aid, mRef!.itemInfo() )
    }
    return data
}