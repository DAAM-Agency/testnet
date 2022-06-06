// add_collection_to_collection.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

transaction(nam: String?, collection: String) {
    let name: String
    let collection: String
    let collectionRef: &DAAM.Collection

    prepare(acct: AuthAccount) {
        self.name = name // Get name of collection
        self.collection = collectionName
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.removePersonalCollection(remove: self.name, collectionName: self.collection) 
        log("Collection Created.")
    }
}
