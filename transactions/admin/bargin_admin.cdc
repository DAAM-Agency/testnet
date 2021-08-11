// answer_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, answer: Bool) {
    let admin: AuthAccount

    prepare(signer: AuthAccount) {
        self.admin = signer
        self.requestGen = self.signer.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
    }

    execute {
        DAAM.barginAdmin(signer: self.admin, mid: mid, status: answer)
        log("Request Answered")
    }
}
