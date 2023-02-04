// remove_tokenID_from_collection.cdc

import DAAM from 0x7db4d10c78bad30a

transaction(id: UInt64, feature: Bool, name: String) {
    let collectionRef : &DAAM.Collection
    let id            : UInt64
    let name          : String
    let feature       : Bool

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
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
