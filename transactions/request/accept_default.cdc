// accept_default.cdc
// Creator selects Royalty between 10% to 30%

import FungibleToken from 0x9a0766d93b6608b7 
import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_Mainnet          from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, percentage: UFix64) {
    let mid         : UInt64
    let percentage  : UFix64
    let requestGen  : &DAAM_Mainnet.RequestGenerator
    let metadataGen : &DAAM_Mainnet.MetadataGenerator
    let royalties   : MetadataViews.Royalties

    prepare(creator: AuthAccount) {
        self.mid     = mid
        self.percentage  = percentage
        self.requestGen  = creator.borrow<&DAAM_Mainnet.RequestGenerator>( from: DAAM_Mainnet.requestStoragePath)!
        self.metadataGen = creator.borrow<&DAAM_Mainnet.MetadataGenerator>(from: DAAM_Mainnet.metadataStoragePath)!

        let royalties    = [ MetadataViews.Royalty(
            receiver: creator.getCapability<&AnyResource{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()),
            cut: percentage,
            description: "Creator Royalty" )
        ]
        self.royalties = MetadataViews.Royalties(royalties)
    }

    pre { percentage >= 0.01 || percentage <= 0.3 }

    execute {
        self.requestGen.acceptDefault(mid: self.mid, metadataGen: self.metadataGen, royalties: self.royalties)
        log("Request Made")
    }
}
