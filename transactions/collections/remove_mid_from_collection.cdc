// remove_mid_from_collection.cdc

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, element: UInt64) {
    let collectionRef: &DAAM_V23.Collection
    let creatorRef   : &DAAM_V23.Creator
    let mid: UInt64
    let element: UInt64

    prepare(acct: AuthAccount) {
<<<<<<< HEAD:transactions/collections/remove_mid_from_collection.cdc
        self.creatorRef = acct.borrow<&DAAM_V23.Creator>(from: DAAM_V23.creatorStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
=======
        self.creatorRef = acct.borrow<&DAAM.Creator>(from: DAAM_V23.creatorStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM_V23.collectionStoragePath)
>>>>>>> tomerge:transactions/collections/remove_mid_to_collection.cdc
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid = mid
        self.element = element
    }

    execute {
        self.collectionRef.collections[self.element].removeMID(creator: self.creatorRef, mid: self.mid) 
        log("MID: ".concat(self.mid.toString()).concat(" added to Collection."))
    }
}
