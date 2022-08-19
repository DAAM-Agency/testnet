// add_tokenID_to_collection.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(id: UInt64, feature: Bool, element: UInt64) {
    let collectionRef: &DAAM.Collection
    let id: UInt64
    let feature: Bool
    let element: UInt64

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.id = id
        self.feature = feature
        self.element = element
    }

    execute {
        self.collectionRef.collections[self.element].addTokenID(id: self.id, feature: self.feature) 
        log("ID: ".concat(self.id.toString()).concat(" added to Collection."))
    }
}
