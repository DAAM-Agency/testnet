// remove_collection.cdc 

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(name: String) {
    let collectionRef : &DAAM_Mainnet.Collection
    let name          : String 

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_Mainnet.Collection>(from: DAAM_Mainnet.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.name = name
    }

    execute {
        self.collectionRef.removeCollection(name: self.name!) 
        log("Collection Removed: index ".concat(self.name))
    }
}
