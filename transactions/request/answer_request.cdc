// make_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, answer: Bool) {
    let signer: AuthAccount

//  if creator is nil then admin else creator


    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        var royality = {DAAM.agency : 0.1 as UFix64}
        royality.insert(key: DAAM.agency, 0.15 as UFix64)        

        let adminRef = self.signer.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        //let creatorRef = self.signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)! 
    

        let requestGen  = self.signer.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)
        if requestGen == nil {  // Create initial Requerst Generator, first time only
            let rh <- adminRef.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- rh, to: DAAM.requestStoragePath)
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPublicPath, target: DAAM.requestStoragePath)!            
            log("Request Generator Initialized")
        }

        requestGen?.answerRequest(mid: mid, answer: answer)
        log("Request Made")
    }
}
