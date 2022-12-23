// item_info_price.cdc
// Return Metadata & Auction Info

import DAAM          from 0xfd43f9148d4b725d
import AuctionHouse  from 0x045a1763c93006ca

// Struct Metadata with Auction Info
pub struct MetadataHolderPrice {
    pub let metadata: DAAM.MetadataHolder
    pub let auction: AuctionHouse.AuctionHolder?

    init(_ metadata: DAAM.MetadataHolder, _ auction: AuctionHouse.AuctionHolder?) {
        self.metadata = metadata
        self.auction = auction //as &AuctionHouse.AuctionHolder?
    }
}

pub fun findAID(_ auction: &AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}?, _ mid: UInt64): UInt64? { // returns AID
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
        .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
        (AuctionHouse.auctionPublicPath)
        .borrow()!

    let metadataRef = getAccount(auction)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!
        
    let metadata = metadataRef.viewMetadata(mid: mid)!
    let aid = findAID(auctionHouse, mid)

    if aid != nil {
        let auctionRef = auctionHouse.item(aid!)! as &AuctionHouse.Auction{AuctionHouse.AuctionPublic}
        let auction = auctionRef!.auctionInfo()
        return MetadataHolderPrice(metadata, auction)
    }
    
    return MetadataHolderPrice(metadata, nil)
}
