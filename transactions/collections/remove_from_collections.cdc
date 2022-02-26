// remove_from_collections.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(tokenID: UInt64) {
    let tokenID : UInt64
    let collectionRef: &DAAM.Collection

    prepare(acct: AuthAccount) {
        self.tokenID = tokenID
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.removeFromCollections(tokenID: self.tokenID) 
        log("Removed from Collection(s).")
    }
}
