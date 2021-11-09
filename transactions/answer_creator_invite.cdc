// answer_creator_invite.cdc

import DAAM_V4 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM_V4.answerCreatorInvite(newCreator: self.signer, submit: submit)

        if creator != nil && submit {
            self.signer.save<@DAAM_V4.Creator>(<- creator!, to: DAAM_V4.creatorStoragePath)!
            self.signer.link<&DAAM_V4.Creator>(DAAM_V4.creatorPrivatePath, target: DAAM_V4.creatorStoragePath)!
            let creatorRef = self.signer.borrow<&DAAM_V4.Creator>(from: DAAM_V4.creatorStoragePath)!
            
            let requestGen <- creatorRef.newRequestGenerator()!
            self.signer.save<@DAAM_V4.RequestGenerator>(<- requestGen, to: DAAM_V4.requestStoragePath)!
            self.signer.link<&DAAM_V4.RequestGenerator>(DAAM_V4.requestPrivatePath, target: DAAM_V4.requestStoragePath)!
            
            let metadataGen <- creatorRef.newMetadataGenerator()!
            self.signer.save<@DAAM{DAAM_V4}.MetadataGenerator>(<- metadataGen, to: DAAM_V4.metadataStoragePath)
            self.signer.link<&DAAM_V4.MetadataGenerator>(DAAM_V4.metadataPublicPath, target: DAAM_V4.metadataStoragePath)

            log("You are now a DAAM Creator: ".concat(self.signer.address.toString()) )
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
