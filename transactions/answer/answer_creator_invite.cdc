// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import DAAM_V20 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let creator <- DAAM_V20.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V20.creatorStoragePath)
            self.signer.save<@DAAM_V20.Creator>(<- creator!, to: DAAM_V20.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V20.Creator>(from: DAAM_V20.creatorStoragePath)!
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_V20.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_V20.MetadataGenerator{DAAM_V20.MetadataGeneratorMint, DAAM_V20.MetadataGeneratorPublic}>(DAAM_V20.metadataPublicPath, target: DAAM_V20.metadataStoragePath)
            self.signer.save<@DAAM_V20.MetadataGenerator>(<- metadataGen, to: DAAM_V20.metadataStoragePath)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V20.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_V20.RequestGenerator>(<- requestGen, to: DAAM_V20.requestStoragePath)
            destroy old_request

            log("You are now a DAAM_V20.Creator." )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }
}