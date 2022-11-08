// remove_tokenID_from_collection.cdc

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(id: UInt64, feature: Bool, name: String) {
    let collectionRef : &DAAM_Mainnet.Collection
    let id            : UInt64
    let name          : String
    let feature       : Bool

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_Mainnet.Collection>(from: DAAM_Mainnet.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.id      = id
        self.feature = feature
        self.name    = name
    }

    execute {
        self.collectionRef.collections[self.name]!.adjustFeatureByID(id: self.id, feature: self.feature) 
        log("ID: ".concat(self.id.toString()).concat(" removed from Collection."))
    }
}
