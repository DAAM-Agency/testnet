// add_to_collection.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

transaction(collectionName: String, tokenID: UInt64) {
    let name: String
    let tokenID : UInt64
    let collectionRef: &DAAM.Collection

    prepare(acct: AuthAccount) {
        self.name = collectionName // Get name of collection
        self.tokenID = tokenID
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.addToPersonalCollection(collectionName: self.name, tokenID: self.tokenID) 
        log("Collection Created.")
    }
}
