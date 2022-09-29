// remove_tokenID_from_collection.cdc

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(id: UInt64, feature: Bool, name: String) {
    let collectionRef: &DAAM_V23.Collection
    let id: UInt64
    let element: Int?
    let feature: Bool

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.id = id
        self.feature = feature

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
        self.collectionRef.collections[self.element!].adjustFeatureByID(id: self.id, feature: self.feature) 
        log("ID: ".concat(self.id.toString()).concat(" removed from Collection."))
    }
}
