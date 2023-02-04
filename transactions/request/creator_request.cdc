// creator_request.cdc

import FungibleToken from 0xf233dcee88fe0abe 
import MetadataViews from 0x1d7e57aa55817448
import DAAM          from 0x7db4d10c78bad30a

transaction(mid: UInt64, percentage: UFix64 ) {
    let mid        : UInt64
    let royalty    : MetadataViews.Royalties
    let requestGen : &DAAM.RequestGenerator
    let metadataGen: &DAAM.MetadataGenerator

    prepare(signer: AuthAccount) {
        let royalties    = [ MetadataViews.Royalty(
            receiver: signer.getCapability<&AnyResource{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()),
            cut: percentage,
            description: "Creator Royalty" )
        ]
        self.royalty = MetadataViews.Royalties(royalties)

        self.mid         = mid
        self.requestGen  = signer.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!
        self.metadataGen = signer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
    }

    execute {
        self.requestGen.createRequest(mid: self.mid, royalty: self.royalty)!
        log("Request Made")
    }
}
