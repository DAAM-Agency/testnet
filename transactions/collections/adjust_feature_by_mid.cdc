// remove_tokenID_from_collection.cdc

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, feature: Bool, name: String) {
    let collectionRef : &DAAMDAAM_Mainnet_Mainnet.Collection
    let creatorRef    : &DAAMDAAM_Mainnet_Mainnet.Creator
    let mid           : UInt64
    let feature       : Bool
    let name          : String

    prepare(acct: AuthAccount) {
        self.creatorRef = acct.borrow<&DAAMDAAM_Mainnet_Mainnet.Creator>(from: DAAM_Mainnet.creatorStoragePath)!
        // Borrow a reference from the stored collection
        self.collectionRef = acct.borrow<&DAAMDAAM_Mainnet_Mainnet.Collection>(from: DAAM_Mainnet.collectionStoragePath)
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
