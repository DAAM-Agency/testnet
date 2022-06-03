// add_collection_to_collection.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V11 from 0xa4ad5ea5c0bd2fba

transaction(collectionName: String, collection: String) {
    let name: String
    let collection: String
    let collectionRef: &DAAM_V11.Collection

    prepare(acct: AuthAccount) {
        self.name = name // Get name of collection
        self.collection = collectionName
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V11.Collection>(from: DAAM_V11.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.addPersonalCollection(addCollection: self.name, collectionName: self.collection) 
        log("Collection Created.")
    }
}
