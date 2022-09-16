// remove_tokenID_from_collection.cdc

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(id: UInt64, element: UInt64) {
    let collectionRef: &DAAM_V23.Collection
    let id: UInt64
    let element: UInt64

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
<<<<<<< HEAD
        self.collectionRef = acct.borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
=======
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM_V23.collectionStoragePath)
>>>>>>> tomerge
            ?? panic("Could not borrow a reference to the owner's collection")
        self.id = id
        self.element = element
    }

    execute {
        self.collectionRef.collections[self.element].removeTokenID(id: self.id) 
        log("ID: ".concat(self.id.toString()).concat(" removed from Collection."))
    }
}
