// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM         from 0xa4ad5ea5c0bd2fba
import AuctionHouse from0x1837e15023c9249

pub fun main(auction: Address): {UInt64 : DAAM.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM.MetadataHolder?} = {}

    for aid in auctions {
        let mRef = auctionHouse.item(aid) as &AuctionHouse.Auction{AuctionHouse.AuctionPublic}?
        data.insert(key: aid, mRef!.itemInfo() )
    }
    return data
}