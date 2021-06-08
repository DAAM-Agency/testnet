// answer_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(request: DAAM.Request, to: Address) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator    = signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)
        let admin      = signer.borrow<&DAAM.Admin>  (from: DAAM.adminStoragePath)
        let entry = (admin != nil) ? admin : creator        

        if entry != nil { // Validate access, Only Creator or Admin
        let requestGen  = signer.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)
            if requestGen == nil {  // Create initial Requerst Generator, first time only
                let rh <- entry.newRequestGenerator()
                self.signer.save<@DAAM.RequestGenerator>(<- rh, to: DAAM.requestStoragePath)
                self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPublicPath, target: DAAM.requestStoragePath)!            
                log("Request Generator Initialized")
            }
        requestGen.makeRequest(metadata: metadata, request: request, send: to)
        log("Request Made")
        }
    }
}
