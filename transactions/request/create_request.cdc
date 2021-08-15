// create_request.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, royality: {Address:UFix64} ) {
    let signer: AuthAccount
    let royality: {Address: UFix64}
    let requestGen: &DAAM.RequestGenerator
    let metadataGen: &DAAM.MetadataGenerator

    prepare(signer: AuthAccount) {
        log(royality.length)
        if royality.length <= 1 { panic("Both parties Must be included.") } // Minimum entry is 2; Agency & Creator

        self.signer = signer
        self.royality = royality
        self.requestGen = self.signer.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!
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
        self.requestGen.createRequest(signer: self.signer, metadata: metadata, royality: self.royality)!
        log("Request Made")
    }
}
