// remove_tokenID_from_collection.cdc

import DAAM from 0x7db4d10c78bad30a

transaction(mid: UInt64, feature: Bool, name: String) {
    let collectionRef : &DAAM.Collection
    let creatorRef    : &DAAM.Creator
    let mid           : UInt64
    let feature       : Bool
    let name          : String

    prepare(acct: AuthAccount) {
        self.creatorRef = acct.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid     = mid
        self.feature = feature
        self.name    = name
    }

    execute {
        self.collectionRef.collections[self.name]!.adjustFeatureByMID(creator: self.creatorRef, mid: self.mid, feature: self.feature) 
        log("ID: ".concat(self.mid.toString()).concat(" removed from Collection."))
    }
}
