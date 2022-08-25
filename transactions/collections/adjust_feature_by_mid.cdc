// remove_tokenID_from_collection.cdc

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, feature: Bool, element: UInt64) {
    let collectionRef: &DAAM_V22.Collection
    let creatorRef   : &DAAM_V22.Creator
    let mid: UInt64
    let feature: Bool
    let element: UInt64

    prepare(acct: AuthAccount) {
<<<<<<< HEAD
        self.creatorRef = acct.borrow<&DAAM_V22.Creator>(from: DAAM_V22.creatorStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V22.Collection>(from: DAAM_V22.collectionStoragePath)
=======
        self.creatorRef = acct.borrow<&DAAM_V22.Creator>(from: DAAM_V22.creatorStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V22.Collection>(from: DAAM_V22.collectionStoragePath)
>>>>>>> 586a0096 (updated FUSD Address)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid = mid
        self.feature = feature
        self.element = element
    }

    execute {
        self.collectionRef.collections[self.element].adjustFeatureByMID(creator: self.creatorRef, mid: self.mid, feature: self.feature) 
        log("ID: ".concat(self.mid.toString()).concat(" removed from Collection."))
    }
}
