// add_to_collection.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V8 from 0xa4ad5ea5c0bd2fba

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(name: String, tokenID: UInt64) {
    let name: String
    let tokenID : UInt64
    let collectionRef: &DAAM_V8.Collection

    prepare(acct: AuthAccount) {
        self.name = name // Get name of collection
        self.tokenID = tokenID
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V8.Collection>(from: DAAM_V8.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.addToCollection(name: self.name, tokenID: self.tokenID) 
        log("Collection Created.")
    }
}