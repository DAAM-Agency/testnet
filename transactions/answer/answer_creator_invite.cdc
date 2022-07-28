// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import DAAM_V19 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let creator <- DAAM_V19.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V19.creatorStoragePath)
            self.signer.save<@DAAM_V19.Creator>(<- creator!, to: DAAM_V19.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V19.Creator>(from: DAAM_V19.creatorStoragePath)!
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_V19.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_V19.MetadataGenerator{DAAM_V19.MetadataGeneratorMint, DAAM_V19.MetadataGeneratorPublic}>(DAAM_V19.metadataPublicPath, target: DAAM_V19.metadataStoragePath)
            self.signer.save<@DAAM_V19.MetadataGenerator>(<- metadataGen, to: DAAM_V19.metadataStoragePath)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V19.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_V19.RequestGenerator>(<- requestGen, to: DAAM_V19.requestStoragePath)
            destroy old_request

            log("You are now a DAAM_V19.Creator." )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }
}