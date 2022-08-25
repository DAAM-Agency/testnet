// remove_collection.cdc 

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(element: Int) {
    let collectionRef: &DAAM_V23.Collection
    let element: Int

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.element = element
    }

    execute {
        self.collectionRef.removeCollection(at: self.element) 
        log("Collection Removed: index ".concat(self.element.toString()))
    }
}
