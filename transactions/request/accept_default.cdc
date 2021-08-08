// accept_default.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64) {
    let signer      : AuthAccount
    let requestGen  : &DAAM.RequestGenerator
    let creator     : &DAAM.Creator
    let metadataGen : &DAAM.MetadataGenerator

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.requestGen = self.signer.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!
        self.creator = self.signer.borrow<&DAAM.Creator>( from: DAAM.creatorStoragePath)!
        self.metadataGen = self.signer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
    }

    execute {
        let rh <- self.creator.newRequestGenerator()
        self.signer.save<@DAAM.RequestGenerator>(<- rh, to: DAAM.requestStoragePath)
        self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPrivatePath, target: DAAM.requestStoragePath)!            
        log("Request Generator Initialized")
    }

    let metadata = metadataGen.getMetadataRef(mid: mid)
    self.requestGen?.acceptDefault(metadata: metadata)!
    log("Request Made")
}
