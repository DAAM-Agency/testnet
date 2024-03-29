// add_mid_to_collection.cdc

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, feature: Bool, name: String) {
    let collectionRef : &DAAM_Mainnet.Collection
    let creatorRef    : &DAAM_Mainnet.Creator
    let mid           : UInt64
    let feature       : Bool
    var name          : String

    prepare(acct: AuthAccount) {
        self.creatorRef = acct.borrow<&DAAM_Mainnet.Creator>(from: DAAM_Mainnet.creatorStoragePath)!
        let metadataGen = acct.borrow<&DAAM_Mainnet.MetadataGenerator>(from: DAAM_Mainnet.metadataStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_Mainnet.Collection>(from: DAAM_Mainnet.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid     = mid
        self.feature = feature
        self.name    = name
    }

    execute {
        self.collectionRef.collections[self.name]!.addMID(creator: self.creatorRef, mid: self.mid, feature: self.feature)
        log("MID: ".concat(self.mid.toString()).concat(" added to Collection."))
    }
}
