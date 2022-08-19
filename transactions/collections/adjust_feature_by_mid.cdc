// remove_tokenID_from_collection.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, feature: Bool, element: UInt64) {
    let collectionRef: &DAAM.Collection
    let id: UInt64
    let element: UInt64

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid = mid
        self.feature = feature
    }

    execute {
        self.collectionRef.collections[self.element].adjustFeatureByMID(mid: self.mid, feature: self.feature) 
        log("ID: ".concat(self.mid.toString()).concat(" removed from Collection."))
    }
}
