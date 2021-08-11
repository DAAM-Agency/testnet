// answer_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, royality: Bool) {
    let creator: AuthAccount

    prepare(signer: AuthAccount) {
        self.creator = signer
        self.requestGen = self.signer.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
    }

    execute {
        DAAM.barginCreator(signer: self.creator, mid: mid, royality: answer)
        log("Request Answered")
    }
}
