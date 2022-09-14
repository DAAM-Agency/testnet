// adjust_feature_by_tokenid.cdc

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(id: UInt64, feature: Bool, element: UInt64) {
    let collectionRef: &DAAM_V23.Collection
    let id: UInt64
    let element: UInt64
    let feature: Bool

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.id = id
        self.feature = feature
        self.element = element
    }

    execute {
        self.collectionRef.collections[self.element].adjustFeatureByID(id: self.id, feature: self.feature) 
        log("ID: ".concat(self.id.toString()).concat(" removed from Collection."))
    }
}
