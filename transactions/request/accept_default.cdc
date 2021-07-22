// accept_default.cdc

import DAAM from 0x0670fa5367e021b7

transaction(mid: UInt64) {
    let signer: AuthAccount
    prepare(signer: AuthAccount) { self.signer = signer }

    execute {
        let requestGen = self.signer.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)
        if requestGen == nil {  // Create initial Requerst Generator, first time only
            let creatorRef = self.signer.borrow<&DAAM.Creator>( from: DAAM.creatorStoragePath)!
            let rh <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- rh, to: DAAM.requestStoragePath)
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPublicPath, target: DAAM.requestStoragePath)!            
            log("Request Generator Initialized")
        }
        let metadataGen = self.signer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        let metadata = metadataGen.getMetadataRef(mid: mid)

        requestGen?.acceptDefault(metadata: metadata)!
        log("Request Made")
    }
}
