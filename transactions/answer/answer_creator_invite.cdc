// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import DAAM_V9 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let creator <- DAAM_V9.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V9.creatorStoragePath)
            self.signer.save<@DAAM_V9.Creator>(<- creator!, to: DAAM_V9.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V9.Creator>(from: DAAM_V9.creatorStoragePath)!
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_V9.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_V9.MetadataGenerator{DAAM_V9.MetadataGeneratorMint, DAAM_V9.MetadataGeneratorPublic}>(DAAM_V9.metadataPublicPath, target: DAAM_V9.metadataStoragePath)
            self.signer.save<@DAAM_V9.MetadataGenerator>(<- metadataGen, to: DAAM_V9.metadataStoragePath)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V9.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_V9.RequestGenerator>(<- requestGen, to: DAAM_V9.requestStoragePath)
            destroy old_request

            log("You are now a DAAM_V9.Creator." )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }
}