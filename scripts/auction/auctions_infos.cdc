// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM_V18         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V7 from 0x01837e15023c9249

pub fun main(auction: Address): {UInt64 : DAAM_V18.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V7.AuctionWallet{AuctionHouse_V7.AuctionWalletPublic}>(AuctionHouse_V7.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM_V18.MetadataHolder?} = {}

    for aid in auctions {
        let mRef = auctionHouse.item(aid) as &AuctionHouse_V7.Auction{AuctionHouse_V7.AuctionPublic}?
        data.insert(key: aid, mRef!.itemInfo() )
    }
    return data
}