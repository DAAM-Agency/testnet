// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import DAAM_V18 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let creator <- DAAM_V18.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V18.creatorStoragePath)
            self.signer.save<@DAAM_V18.Creator>(<- creator!, to: DAAM_V18.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V18.Creator>(from: DAAM_V18.creatorStoragePath)!
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_V18.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_V18.MetadataGenerator{DAAM_V18.MetadataGeneratorMint, DAAM_V18.MetadataGeneratorPublic}>(DAAM_V18.metadataPublicPath, target: DAAM_V18.metadataStoragePath)
            self.signer.save<@DAAM_V18.MetadataGenerator>(<- metadataGen, to: DAAM_V18.metadataStoragePath)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V18.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_V18.RequestGenerator>(<- requestGen, to: DAAM_V18.requestStoragePath)
            destroy old_request

            log("You are now a DAAM_V18.Creator." )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }
}