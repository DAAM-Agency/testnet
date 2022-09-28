// remove_tokenID_from_collection.cdc

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, feature: Bool, name: String) {
    let collectionRef: &DAAM_V23.Collection
    let creatorRef   : &DAAM_V23.Creator
    let mid: UInt64
    let feature: Bool
    let name: String

    prepare(acct: AuthAccount) {
        self.creatorRef = acct.borrow<&DAAM_V23.Creator>(from: DAAM_V23.creatorStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid = mid
        self.feature = feature
        self.name = name
    }

    execute {
        self.collectionRef.collections[self.name]!.adjustFeatureByMID(creator: self.creatorRef, mid: self.mid, feature: self.feature) 
        log("ID: ".concat(self.mid.toString()).concat(" removed from Collection."))
    }
}
