// remove_mid_from_collection.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, element: UInt64) {
    let collectionRef: &DAAM.Collection
    let mid: UInt64
    let element: UInt64

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid = mid
    }

    execute {
        self.collectionRef.collections[self.element].removeMID(mid: self.mid) 
        log("MID: ".concat(self.mid.toString()).concat(" added to Collection."))
    }
}
