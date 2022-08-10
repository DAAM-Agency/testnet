// add_to_collection.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

transaction(element: Int) {
    let collectionRef: &DAAM.Collection
    let element: Int

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.element = element
    }

    execute {
        self.collectionRef.removeCollection(at: self.element) 
        log("Collection Removed: index ".concat(self.element.toString()))
    }
}
