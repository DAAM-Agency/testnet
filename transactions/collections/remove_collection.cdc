// remove_collection.cdc 

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(name: String) {
    let collectionRef: &DAAM_V23.Collection
    let element: Int?

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        
        let list = self.collectionRef.getCollection()
        var counter = 0
        var elm_found = false

        for elm in list {
            if list[counter].display.name == name {
                elm_found = true
                break
            }
            counter = counter + 1
        }

        self.element = elm_found ? counter : nil
    }

    execute {
        self.collectionRef.removeCollection(at: self.element!) 
        log("Collection Removed: index ".concat(self.element!.toString()))
    }
}
