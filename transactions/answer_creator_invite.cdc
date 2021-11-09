// answer_creator_invite.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM_V5.answerCreatorInvite(newCreator: self.signer, submit: submit)

        if creator != nil && submit {
            self.signer.save<@DAAM_V5.Creator>(<- creator!, to: DAAM_V5.creatorStoragePath)!
            self.signer.link<&DAAM_V5.Creator>(DAAM_V5.creatorPrivatePath, target: DAAM_V5.creatorStoragePath)!
            let creatorRef = self.signer.borrow<&DAAM_V5.Creator>(from: DAAM_V5.creatorStoragePath)!
            
            let requestGen <- creatorRef.newRequestGenerator()!
            self.signer.save<@DAAM_V5.RequestGenerator>(<- requestGen, to: DAAM_V5.requestStoragePath)!
            self.signer.link<&DAAM_V5.RequestGenerator>(DAAM_V5.requestPrivatePath, target: DAAM_V5.requestStoragePath)!
            
            let metadataGen <- creatorRef.newMetadataGenerator()!
            self.signer.save<@DAAM{DAAM_V5}.MetadataGenerator>(<- metadataGen, to: DAAM_V5.metadataStoragePath)
            self.signer.link<&DAAM_V5.MetadataGenerator>(DAAM_V5.metadataPublicPath, target: DAAM_V5.metadataStoragePath)

            log("You are now a DAAM Creator: ".concat(self.signer.address.toString()) )
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
