// remove_from_collections.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V9 from 0xa4ad5ea5c0bd2fba

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(tokenID: UInt64) {
    let tokenID : UInt64
    let collectionRef: &DAAM_V9.Collection

    prepare(acct: AuthAccount) {
        self.tokenID = tokenID
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V9.Collection>(from: DAAM_V9.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.removeFromCollections(tokenID: self.tokenID) 
        log("Removed from Collection(s).")
    }
}
