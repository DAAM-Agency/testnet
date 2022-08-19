// add_mid_to_collection.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, feature: Bool) {
    let collectionRef: &DAAM.Collection
    let mid: UInt64
    let feature: Bool

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid = mid
        self.feature = feature
    }

    execute {
        self.collectionRef.collections[0].addMid(mid: self.mid, feature: self.feature) 
        log("MID: ".concat(self.mid.toString()).concat(" added to Collection."))
    }
}
