// remove_from_collection.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

transaction(collection_name: String?, tokenID: UInt64) {
    let name: String?
    let tokenID : UInt64
    let collectionRef: &DAAM.Collection

    prepare(acct: AuthAccount) {
        self.name = collection_name // Get name of collection
        self.tokenID = tokenID
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    }

    execute {
        self.collectionRef.removeFromCollection(collectionName: self.name, tokenID: self.tokenID) 
        log("Remove TokenID ".concat(tokenID.toString()).concat(" from Collection: ").concat(name) )
    }
}
