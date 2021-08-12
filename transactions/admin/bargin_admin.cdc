// bargin_admin.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, royality: {Address : UFix64} ) {
    let mid        : UInt64
    let royality   : {Address : UFix64}
    let admin      : AuthAccount
    let requestGen : &DAAM.RequestGenerator

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.royality = royality
        self.admin = admin
        self.requestGen = self.admin.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
    }

    execute {
        DAAM.barginAdmin(admin: self.admin, mid: self.mid, royality: self.royality)
        log("Request Answered")
    }
}
