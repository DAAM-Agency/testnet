// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import Profile from 0x192440c99cb17282
import DAAM    from 0xfd43f9148d4b725d

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

        let creator <- DAAM.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            self.signer.save<@DAAM.Creator>(<- creator!, to: DAAM.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!

            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint, DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath, target: DAAM.metadataStoragePath)
            self.signer.save<@DAAM.MetadataGenerator>(<- metadataGen, to: DAAM.metadataStoragePath)

            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)

            log("You are now a DAAM Creator." )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }

    post { Profile.check(self.signer.address): "Account was not initialized" }
}