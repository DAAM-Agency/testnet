// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM_V6.answerCreatorInvite(newCreator: self.signer, submit: submit)

        if creator != nil && submit {
            self.signer.save<@DAAM_V6.Creator>(<- creator!, to: DAAM_V6.creatorStoragePath)!
            self.signer.link<&DAAM_V6.Creator>(DAAM_V6.creatorPrivatePath, target: DAAM_V6.creatorStoragePath)!
            let creatorRef = self.signer.borrow<&DAAM_V6.Creator>(from: DAAM_V6.creatorStoragePath)!
            
            let requestGen <- creatorRef.newRequestGenerator()!
            self.signer.save<@DAAM_V6.RequestGenerator>(<- requestGen, to: DAAM_V6.requestStoragePath)!
            self.signer.link<&DAAM_V6.RequestGenerator>(DAAM_V6.requestPrivatePath, target: DAAM_V6.requestStoragePath)!
            
            let metadataGen <- creatorRef.newMetadataGenerator()!
            self.signer.save<@DAAM_V6.MetadataGenerator>(<- metadataGen, to: DAAM_V6.metadataStoragePath)
            self.signer.link<&DAAM_V6.MetadataGenerator>(DAAM_V6.metadataPublicPath, target: DAAM_V6.metadataStoragePath)

            log("You are now a DAAM_V6 Creator: ".concat(self.signer.address.toString()) )
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
