// add_to_collection.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V17 from 0xa4ad5ea5c0bd2fba

transaction(collectionName: String, tokenID: UInt64) {
    let name: String
    let tokenID : UInt64
    let collectionRef: &DAAM_V17.Collection

    prepare(acct: AuthAccount) {
        self.name = collectionName // Get name of collection
        self.tokenID = tokenID
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V17.Collection>(from: DAAM_V17.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.addToPersonalCollection(collectionName: self.name, tokenID: self.tokenID) 
        log("Collection Created.")
    }
}
