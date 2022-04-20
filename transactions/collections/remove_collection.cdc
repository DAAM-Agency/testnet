// remove_collection.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V8 from 0xa4ad5ea5c0bd2fba

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(name: String) {
    let name: String
    let collectionRef: &DAAM_V8.Collection

    prepare(acct: AuthAccount) {
        self.name = name // Get name of collection
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V8.Collection>(from: DAAM_V8.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.removeCollection(name: self.name) 
        log("Collection Created.")
    }
}