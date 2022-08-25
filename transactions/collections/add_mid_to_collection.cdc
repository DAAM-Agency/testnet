// add_mid_to_collection.cdc

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, feature: Bool, element: UInt64) {
    let collectionRef: &DAAM_V23.Collection
    let creatorRef   : &DAAM_V23.Creator
    let mid: UInt64
    let feature: Bool
    let element: UInt64

    prepare(acct: AuthAccount) {
        self.creatorRef = acct.borrow<&DAAM_V23.Creator>(from: DAAM_V23.creatorStoragePath)!
        let metadataGen = acct.borrow<&DAAM_V23.MetadataGenerator>(from: DAAM_V23.metadataStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid = mid
        self.feature = feature
        self.element = element
    }

    execute {
        self.collectionRef.collections[self.element].addMID(creator: self.creatorRef, mid: self.mid, feature: self.feature)
        log("MID: ".concat(self.mid.toString()).concat(" added to Collection."))
    }
}
