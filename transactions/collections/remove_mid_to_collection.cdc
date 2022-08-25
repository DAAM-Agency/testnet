// remove_mid_from_collection.cdc

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, element: UInt64) {
    let collectionRef: &DAAM_V22.Collection
    let creatorRef   : &DAAM_V22.Creator
    let mid: UInt64
    let element: UInt64

    prepare(acct: AuthAccount) {
        self.creatorRef = acct.borrow<&DAAM_V22.Creator>(from: DAAM_V22.creatorStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V22.Collection>(from: DAAM_V22.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid = mid
        self.element = element
    }

    execute {
        self.collectionRef.collections[self.element].removeMID(creator: self.creatorRef, mid: self.mid) 
        log("MID: ".concat(self.mid.toString()).concat(" added to Collection."))
    }
}
