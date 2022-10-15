// bargin.cdc
import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, royality: {Address : UFix64} ) {
    let mid        : UInt64
    let royality   : {Address : UFix64}
    let signer     : AuthAccount
    let requestGen : &DAAM.RequestGenerator

    prepare(signer: AuthAccount) {
        self.mid = mid
        self.royality = royality
        self.signer = signer
        self.requestGen = self.signer.borrow<&DAAM.RequestGenerator>(from: DAAM_V3.requestStoragePath)!
    }

    execute {
        DAAM.bargin(mid: self.mid, royality: self.royality)
        log("Request Answered")
    }
}