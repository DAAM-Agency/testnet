// creator_request.cdc

import FungibleToken from 0xee82856bf20e2aa6 
import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM          from 0xfd43f9148d4b725d

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
