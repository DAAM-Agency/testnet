// creator_request.cdc

import FungibleToken from 0x9a0766d93b6608b7 
import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_Mainnet          from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, percentage: UFix64 ) {
    let mid        : UInt64
    let royalty    : MetadataViews.Royalties
    let requestGen : &DAAM_Mainnet.RequestGenerator
    let metadataGen: &DAAM_Mainnet.MetadataGenerator

    prepare(signer: AuthAccount) {
        let royalties    = [ MetadataViews.Royalty(
            receiver: signer.getCapability<&AnyResource{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()),
            cut: percentage,
            description: "Creator Royalty" )
        ]
        self.royalty = MetadataViews.Royalties(royalties)

        self.mid         = mid
        self.requestGen  = signer.borrow<&DAAM_Mainnet.RequestGenerator>( from: DAAM_Mainnet.requestStoragePath)!
        self.metadataGen = signer.borrow<&DAAM_Mainnet.MetadataGenerator>(from: DAAM_Mainnet.metadataStoragePath)!
    }

    execute {
        self.requestGen.createRequest(mid: self.mid, royalty: self.royalty)!
        log("Request Made")
    }
}
