// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import Profile from 0xe223d8a629e49c68
import DAAM_V8.V8.V8_V8..    from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        if !Profile.check(self.signer.address) {
            self.signer.save(<- Profile.new(), to: Profile.privatePath)
            self.signer.link<&Profile.Base{Profile.Public}>(Profile.publicPath, target: Profile.privatePath)
        }

        let creator <- DAAM_V8.V8..answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            self.signer.save<@DAAM_V8.V8..Creator>(<- creator!, to: DAAM_V8.V8..creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V8.V8..Creator>(from: DAAM_V8.V8..creatorStoragePath)!

            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_V8.V8..MetadataGenerator{DAAM_V8.V8..MetadataGeneratorMint, DAAM_V8.V8..MetadataGeneratorPublic}>(DAAM_V8.V8..metadataPublicPath, target: DAAM_V8.V8..metadataStoragePath)
            self.signer.save<@DAAM_V8.V8..MetadataGenerator>(<- metadataGen, to: DAAM_V8.V8..metadataStoragePath)

            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_V8.V8..RequestGenerator>(<- requestGen, to: DAAM_V8.V8..requestStoragePath)

            log("You are now a DAAM_V8.V8..Creator." )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }

    post { Profile.check(self.signer.address): "Account was not initialized" }
}