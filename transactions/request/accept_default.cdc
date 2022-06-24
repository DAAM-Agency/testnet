// accept_default.cdc
// Creator selects Royalty between 10% to 30%

import FungibleToken from 0x9a0766d93b6608b7 
import MetadataViews from 0x631e88ae7f1d7c20
<<<<<<< HEAD
import DAAM_V14          from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V15          from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15

transaction(mid: UInt64, percentage: UFix64) {
    let mid         : UInt64
    let percentage  : UFix64
<<<<<<< HEAD
    let requestGen  : &DAAM_V14.RequestGenerator
    let metadataGen : &DAAM_V14.MetadataGenerator
=======
    let requestGen  : &DAAM_V15.RequestGenerator
    let metadataGen : &DAAM_V15.MetadataGenerator
>>>>>>> DAAM_V15
    let royalties   : MetadataViews.Royalties

    prepare(creator: AuthAccount) {
        self.mid     = mid
        self.percentage  = percentage
<<<<<<< HEAD
        self.requestGen  = creator.borrow<&DAAM_V14.RequestGenerator>( from: DAAM_V14.requestStoragePath)!
        self.metadataGen = creator.borrow<&DAAM_V14.MetadataGenerator>(from: DAAM_V14.metadataStoragePath)!
=======
        self.requestGen  = creator.borrow<&DAAM_V15.RequestGenerator>( from: DAAM_V15.requestStoragePath)!
        self.metadataGen = creator.borrow<&DAAM_V15.MetadataGenerator>(from: DAAM_V15.metadataStoragePath)!
>>>>>>> DAAM_V15

        let royalties    = [ MetadataViews.Royalty(
            recipient: creator.getCapability<&AnyResource{FungibleToken.Receiver}>(/public/fusdReceiver),
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
