// add_collection_to_collection.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15

transaction(collectionName: String, collection: String) {
    let name: String
    let collection: String
<<<<<<< HEAD
    let collectionRef: &DAAM_V14.Collection
=======
    let collectionRef: &DAAM_V15.Collection
>>>>>>> DAAM_V15

    prepare(acct: AuthAccount) {
        self.name = name // Get name of collection
        self.collection = collectionName
        // Borrow a reference from the stored collection
<<<<<<< HEAD
        self.collectionRef = acct.borrow<&DAAM_V14.Collection>(from: DAAM_V14.collectionStoragePath)
=======
        self.collectionRef = acct.borrow<&DAAM_V15.Collection>(from: DAAM_V15.collectionStoragePath)
>>>>>>> DAAM_V15
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.addPersonalCollection(addCollection: self.name, collectionName: self.collection) 
        log("Collection Created.")
    }
}
