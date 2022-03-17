// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let creator <- DAAM.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let metadataGen <- creator.newMetadataGenerator()
            self.signer.link<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint, DAAM.MetadataGeneratorPublic}>(DAAM.metadataPrivatePath, target: DAAM.metadataStoragePath)
            metadataGen.activate(creator: self.signer)
            self.signer.save<@DAAM.MetadataGenerator>(<- metadataGen, to: DAAM.metadataStoragePath)
            
            let requestGen  <- creator.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)

            self.signer.save<@DAAM.Creator>(<- creator!, to: DAAM.creatorStoragePath)
            
            log("You are now a DAAM Creator: ".concat(self.signer.address.toString()) )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }
}