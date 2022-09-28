// remove_mid_from_collection.cdc

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, name: String) {
    let collectionRef: &DAAM_V23.Collection
    let creatorRef   : &DAAM_V23.Creator
    let mid: UInt64
    let name: String

    prepare(acct: AuthAccount) {
        self.creatorRef = acct.borrow<&DAAM_V23.Creator>(from: DAAM_V23.creatorStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid = mid
        self.name = name
    }

    execute {
        self.collectionRef.collections[self.name]!.removeMID(creator: self.creatorRef, mid: self.mid) 
        log("MID: ".concat(self.mid.toString()).concat(" added to Collection."))
    }
}
