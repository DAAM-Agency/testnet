// make_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64) {
    let signer: AuthAccount
    let requestGen: &DAAM.RequestGenerator
    let metadataGen: &DAAM.MetadataGenerator

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.requestGen = self.signer.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)
        self.metadataGen = self.signer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
    }

    execute {
        if self.requestGen == nil {  // Create initial Requerst Generator, first time only
            let rh <- self.signer.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath) != nil ?
            (self.signer.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath))!.newRequestGenerator() : 
            (self.signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath))!.newRequestGenerator()

            self.signer.save<@DAAM.RequestGenerator>(<- rh, to: DAAM.requestStoragePath)
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPrivatePath, target: DAAM.requestStoragePath)!            
            log("Request Generator Initialized")
        }
        let metadata = self.metadataGen.getMetadataRef(mid: mid)

        var royality = {DAAM.agency : 0.15 as UFix64} // Debug
        royality.insert(key: metadata.creator, 0.10 as UFix64) // Debug

        requestGen?.makeRequest(metadata: metadata, royality: royality)!
        log("Request Made")
    }
}
