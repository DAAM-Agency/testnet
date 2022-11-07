// auctions_infos.cdc
// Return all auctions in Auction Wallet. Identified by AuctionIDs

import DAAM_Mainnet         from 0xfd43f9148d4b725d
import AuctionHouse_Mainnet from 0x045a1763c93006ca

pub fun main(auction: Address): {UInt64 : DAAM_Mainnet.MetadataHolder?}
{    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>(AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!

    let auctions =  auctionHouse.getAuctions()
    var data: {UInt64 : DAAM_Mainnet.MetadataHolder?} = {}

    for aid in auctions {
        let mRef = auctionHouse.item(aid) as &AuctionHouse_Mainnet.Auction{AuctionHouse_Mainnet.AuctionPublic}?
        data.insert(key: aid, mRef!.itemInfo() )
    }
    return data
}