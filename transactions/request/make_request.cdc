// make_request.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64 /* , creator: Address?*/ ) {
    let signer: AuthAccount

//  if creator is nil then admin else creator


    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        var royality = {DAAM.agency : 0.1 as UFix64} // Debug

        //let admin = self.signer.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        let creatorRef = self.signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!
        let requestGen  = self.signer.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)
        if requestGen == nil {  // Create initial Requerst Generator, first time only
            let rh <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- rh, to: DAAM.requestStoragePath)
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPublicPath, target: DAAM.requestStoragePath)!            
            log("Request Generator Initialized")
        }
        let metadataGen = self.signer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        let metadata = metadataGen.getMetadataRef(mid: mid)

        royality.insert(key: metadata.creator, 0.15 as UFix64) // Debug

        requestGen?.makeRequest(metadata: metadata, royality: royality)!
        log("Request Made")
    }
}
