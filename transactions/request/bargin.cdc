// bargin.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, royality: {Address : UFix64} ) {
    let mid        : UInt64
    let royality   : {Address : UFix64}
    let signer     : AuthAccount
    let requestGen : &DAAM_V1.RequestGenerator

    prepare(signer: AuthAccount) {
        self.mid = mid
        self.royality = royality
        self.signer = signer
        self.requestGen = self.signer.borrow<&DAAM_V1.RequestGenerator>(from: DAAM_V1.requestStoragePath)!
    }

    execute {
        DAAM_V1.bargin(signer: self.signer, mid: self.mid, royality: self.royality)
        log("Request Answered")
    }
}
