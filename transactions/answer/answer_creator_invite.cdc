// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer        
    }

    execute {
        let creator <- DAAM.answerCreatorInvite(newCreator: self.signer, submit: submit)
        if creator != nil {
            self.signer.save<@DAAM.Creator>(<- creator!, to: DAAM.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!
            
            let requestGen <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)
            
            let metadataGen <- creatorRef.newMetadataGenerator()
            //self.signer.link<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic, DAAM.MetadataGeneratorMint}>(DAAM.metadataPrivatePath, target: DAAM.metadataStoragePath)
            let metadataGenCap = self.signer.getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPrivatePath)
            metadataGen.activate(creator: self.signer, metadata: metadataGenCap)
            self.signer.save<@DAAM.MetadataGenerator>(<- metadataGen, to: DAAM.metadataStoragePath)

            log("You are now a DAAM Creator: ".concat(self.signer.address.toString()) )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }
}