// remove_collection.cdc 

import DAAM from 0x7db4d10c78bad30a

transaction(name: String) {
    let collectionRef : &DAAM.Collection
    let name          : String 

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.name = name
    }

    execute {
        self.collectionRef.removeCollection(name: self.name!) 
        log("Collection Removed: index ".concat(self.name))
    }
}
