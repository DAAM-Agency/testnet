// remove_from_collection.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V14

transaction(collection_name: String?, tokenID: UInt64) {
    let name: String?
    let tokenID : UInt64
<<<<<<< HEAD
    let collectionRef: &DAAM_V10.Collection
=======
    let collectionRef: &DAAM_V14.Collection
>>>>>>> DAAM_V14

    prepare(acct: AuthAccount) {
        self.name = collection_name // Get name of collection
        self.tokenID = tokenID
        // Borrow a reference from the stored collection
<<<<<<< HEAD
        self.collectionRef = acct.borrow<&DAAM_V10.Collection>(from: DAAM_V10.collectionStoragePath)
=======
        self.collectionRef = acct.borrow<&DAAM_V14.Collection>(from: DAAM_V14.collectionStoragePath)
>>>>>>> DAAM_V14
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.removeFromCollection(collectionName: self.name, tokenID: self.tokenID) 
        log("Remove TokenID ".concat(tokenID.toString()).concat(" from Collection: ").concat(name) )
    }
}
