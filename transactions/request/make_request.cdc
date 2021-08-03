// make_request.cdc

import DAAM from 0x0670fa5367e021b7

transaction(mid: UInt64) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        var royality = {DAAM.agency : 0.1 as UFix64} // Debug

        let requestGen = self.signer.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)
        if requestGen == nil {  // Create initial Requerst Generator, first time only
	    let rh <- self.signer.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath) != nil ?
		(self.signer.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath))!.newRequestGenerator() : 
		(self.signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath))!.newRequestGenerator() 
            self.signer.save<@DAAM.RequestGenerator>(<- rh, to: DAAM.requestStoragePath)
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPublicPath, target: DAAM.requestStoragePath)!            
            log("Request Generator Initialized")
        }
        let metadataGen = self.signer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        let metadata = metadataGen.getMetadataRef(mid: mid)

        royality.insert(key: metadata.creator, 0.10 as UFix64) // Debug

        requestGen?.makeRequest(metadata: metadata, royality: royality)!
        log("Request Made")
    }
}
