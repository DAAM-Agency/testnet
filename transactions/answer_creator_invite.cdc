// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM_V7.answerCreatorInvite(newCreator: self.signer, submit: submit)

        if creator != nil && submit {
            self.signer.save<@DAAM_V7.Creator>(<- creator!, to: DAAM_V7.creatorStoragePath)!
            self.signer.link<&DAAM_V7.Creator>(DAAM_V7.creatorPrivatePath, target: DAAM_V7.creatorStoragePath)!
            let creatorRef = self.signer.borrow<&DAAM_V7.Creator>(from: DAAM_V7.creatorStoragePath)!
            
            let requestGen <- creatorRef.newRequestGenerator()!
            self.signer.save<@DAAM_V7.RequestGenerator>(<- requestGen, to: DAAM_V7.requestStoragePath)!
            self.signer.link<&DAAM_V7.RequestGenerator>(DAAM_V7.requestPrivatePath, target: DAAM_V7.requestStoragePath)!
            
            let metadataGen <- creatorRef.newMetadataGenerator()!
            self.signer.save<@DAAM_V7.MetadataGenerator>(<- metadataGen, to: DAAM_V7.metadataStoragePath)
            self.signer.link<&DAAM_V7.MetadataGenerator>(DAAM_V7.metadataPublicPath, target: DAAM_V7.metadataStoragePath)

            log("You are now a DAAM_V7 Creator: ".concat(self.signer.address.toString()) )
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
