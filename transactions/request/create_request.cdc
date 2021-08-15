// create_request.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, royality: {Address:UFix64} ) {
    let signer: AuthAccount
    let royality: {Address: UFix64}
    let requestGen: &DAAM_V1.RequestGenerator
    let metadataGen: &DAAM_V1.MetadataGenerator

    prepare(signer: AuthAccount) {
        log(royality.length)
        if royality.length <= 1 { panic("Both parties Must be included.") } // Minimum entry is 2; Agency & Creator

        self.signer = signer
        self.royality = royality
        self.requestGen = self.signer.borrow<&DAAM_V1.RequestGenerator>( from: DAAM_V1.requestStoragePath)!
        self.metadataGen = self.signer.borrow<&DAAM_V1.MetadataGenerator>(from: DAAM_V1.metadataStoragePath)!
    }

    execute {
        if self.requestGen == nil {  // Create initial Requerst Generator, first time only
            let rh <- self.signer.borrow<&DAAM_V1.Admin>(from: DAAM_V1.adminStoragePath) != nil ?
            (self.signer.borrow<&DAAM_V1.Admin>(from: DAAM_V1.adminStoragePath))!.newRequestGenerator() : 
            (self.signer.borrow<&DAAM_V1.Creator>(from: DAAM_V1.creatorStoragePath))!.newRequestGenerator()

            self.signer.save<@DAAM_V1.RequestGenerator>(<- rh, to: DAAM_V1.requestStoragePath)
            self.signer.link<&DAAM_V1.RequestGenerator>(DAAM_V1.requestPrivatePath, target: DAAM_V1.requestStoragePath)!            
            log("Request Generator Initialized")
        }

        let metadata = self.metadataGen.getMetadataRef(mid: mid)
        self.requestGen.createRequest(signer: self.signer, metadata: metadata, royality: self.royality)!
        log("Request Made")
    }
}
