// item_info_price.cdc
// Return Metadata & Auction Info

import DAAM_Mainnet          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet  from 0x01837e15023c9249

// Struct Metadata with Auction Info
pub struct MetadataHolderPrice {
    pub let metadata: DAAM_Mainnet.MetadataHolder
    pub let auction: AuctionHouse_Mainnet.AuctionHolder?

    init(_ metadata: DAAM_Mainnet.MetadataHolder, _ auction: AuctionHouse_Mainnet.AuctionHolder?) {
        self.metadata = metadata
        self.auction = auction //as &AuctionHouse_Mainnet.AuctionHolder?
    }
}

pub fun findAID(_ auction: &AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}?, _ mid: UInt64): UInt64? { // returns AID
    if auction == nil { return nil }
    let currentAuctions= auction!.getAuctions()
    for aid in currentAuctions {
        let item_mid = auction!.item(aid!)?.auctionInfo()?.mid
        if item_mid == mid { return aid }
    }
    return nil
}

pub fun main(auction: Address, mid: UInt64): MetadataHolderPrice {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
        (AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!

    let metadataRef = getAccount(auction)
        .getCapability<&DAAM_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorPublic}>(DAAM_Mainnet.metadataPublicPath)
        .borrow()!
        
    let metadata = metadataRef.viewMetadata(mid: mid)!
    let aid = findAID(auctionHouse, mid)

    if aid != nil {
        let auctionRef = auctionHouse.item(aid!)! as &AuctionHouse_Mainnet.Auction{AuctionHouse_Mainnet.AuctionPublic}
        let auction = auctionRef!.auctionInfo()
        return MetadataHolderPrice(metadata, auction)
    }
    
    return MetadataHolderPrice(metadata, nil)
}
