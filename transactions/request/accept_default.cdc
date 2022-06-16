// accept_default.cdc
// Creator selects Royalty between 10% to 30%

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba
=======
import FungibleToken from 0x9a0766d93b6608b7 
import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V14          from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V14

transaction(mid: UInt64, percentage: UFix64) {
    let mid         : UInt64
    let percentage  : UFix64
<<<<<<< HEAD
    let requestGen  : &DAAM_V10.RequestGenerator
    let metadataGen : &DAAM_V10.MetadataGenerator
=======
    let requestGen  : &DAAM_V14.RequestGenerator
    let metadataGen : &DAAM_V14.MetadataGenerator
    let royalties   : MetadataViews.Royalties
>>>>>>> DAAM_V14

    prepare(creator: AuthAccount) {
        self.mid     = mid
        self.percentage  = percentage
<<<<<<< HEAD
        self.requestGen  = creator.borrow<&DAAM_V10.RequestGenerator>( from: DAAM_V10.requestStoragePath)!
        self.metadataGen = creator.borrow<&DAAM_V10.MetadataGenerator>(from: DAAM_V10.metadataStoragePath)!
=======
        self.requestGen  = creator.borrow<&DAAM_V14.RequestGenerator>( from: DAAM_V14.requestStoragePath)!
        self.metadataGen = creator.borrow<&DAAM_V14.MetadataGenerator>(from: DAAM_V14.metadataStoragePath)!

        let royalties    = [ MetadataViews.Royalty(
            recipient: creator.getCapability<&AnyResource{FungibleToken.Receiver}>(/public/fusdReceiver),
            cut: percentage,
            description: "Creator Royalty" )
        ]
        self.royalties = MetadataViews.Royalties(royalties)
>>>>>>> DAAM_V14
    }

    pre { percentage >= 0.01 || percentage <= 0.3 }

    execute {
        self.requestGen.acceptDefault(mid: self.mid, metadataGen: self.metadataGen, royalties: self.royalties)
        log("Request Made")
    }
}
