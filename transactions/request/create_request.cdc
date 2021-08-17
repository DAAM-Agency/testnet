// create_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, royality: {Address:UFix64} ) {
    let signer: AuthAccount
    let royality: {Address: UFix64}
    let requestGen: &DAAM.RequestGenerator
    let metadataGen: &DAAM.MetadataGenerator

    prepare(signer: AuthAccount) {
        if royality.length <= 1 { panic("Both parties Must be included.") } // Minimum entry is 2; Agency & Creator

        self.signer   = signer
        self.royality = royality
        self.metadataGen = self.signer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        self.requestGen  = self.signer.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
    }

    execute {
        let metadata = self.metadataGen.getMetadataRef(mid: mid)
        self.requestGen.createRequest(signer: self.signer, metadata: metadata, royality: self.royality)!
        log("Request Made")
    }
}
