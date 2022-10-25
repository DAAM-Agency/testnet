// remove_mid_from_collection.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, name: String) {
    let collectionRef : &DAAM.Collection
    let creatorRef    : &DAAM.Creator
    let mid           : UInt64
    let name          : String

    prepare(acct: AuthAccount) {
        self.creatorRef    = acct.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)! // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        self.mid  = mid
        self.name = name
    }

    execute {
        self.collectionRef.collections[self.name!].removeMID(creator: self.creatorRef, mid: self.mid) 
        log("MID: ".concat(self.mid.toString()).concat(" added to Collection."))
    }
}
