// bargin.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, royality: {Address : UFix64} ) {
    let mid        : UInt64
    let royality   : {Address : UFix64}
    let signer     : AuthAccount
    let requestGen : &DAAM.RequestGenerator

    prepare(signer: AuthAccount) {
        self.mid = mid
        self.royality = royality
        self.signer = signer
        self.requestGen = self.signer.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
    }

    execute {
        DAAM.bargin(signer: self.signer, mid: self.mid, royality: self.royality)
        log("Request Answered")
    }
}
