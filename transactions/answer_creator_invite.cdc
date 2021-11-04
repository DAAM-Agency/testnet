// answer_creator_invite.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM.answerCreatorInvite(newCreator: self.signer, submit: submit)

        if creator != nil && submit {
            self.signer.save<@DAAM.Creator>(<- creator!, to: DAAM.creatorStoragePath)!
            self.signer.link<&DAAM.Creator>(DAAM.creatorPrivatePath, target: DAAM.creatorStoragePath)!
            let creatorRef = self.signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!
            
            let requestGen <- creatorRef.newRequestGenerator()!
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)!
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPrivatePath, target: DAAM.requestStoragePath)!
            
            let metadataGen <- creatorRef.newMetadataGenerator()!
            self.signer.link<&DAAM.MetadataGenerator>(DAAM.metadataPublicPath, target: DAAM.metadataStoragePath)
            self.signer.save<@DAAM.MetadataGenerator>(<- metadataGen, to: DAAM.metadataStoragePath)

            let metadataCap = self.signer.getCapability<&DAAM.MetadataGenerator>(DAAM.metadataPublicPath)!
            let metadataRef = self.signer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
            metadataRef.activate(metadataGenerator: metadataCap)

            log("You are now a DAAM Creator: ".concat(self.signer.address.toString()) )
        }

        if !submit { log("Thank You for your consideration.") }
    }
}
