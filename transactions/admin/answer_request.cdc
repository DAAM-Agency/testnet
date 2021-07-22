// answer_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, answer: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        var royality = {DAAM.agency : 0.1 as UFix64}
        royality.insert(key: DAAM.agency, 0.15 as UFix64)        

        let adminRef = self.signer.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        if self.signer.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath) == nil {  // Create initial Requerst Generator, first time only
            let requestGen <- adminRef.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPublicPath, target: DAAM.requestStoragePath)            
            log("Request Generator Initialized")
        }
        adminRef.answerRequest(mid: mid, answer: answer)
        log("Request Answered")
    }
}
