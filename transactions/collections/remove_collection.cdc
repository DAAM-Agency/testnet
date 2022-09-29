// remove_collection.cdc 

import DAAM from 0xfd43f9148d4b725d

transaction(name: String) {
    let collectionRef: &DAAM.Collection
    let element: Int?

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
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
