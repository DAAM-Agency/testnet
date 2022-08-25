// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import Profile from 0xba1132bc08f82fe2
import DAAM_V22    from 0xa4ad5ea5c0bd2fba

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

        let creator <- DAAM_V22.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
<<<<<<< HEAD
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V22.creatorStoragePath)
            self.signer.save<@DAAM_V22.Creator>(<- creator!, to: DAAM_V22.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V22.Creator>(from: DAAM_V22.creatorStoragePath)!
=======
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V22.creatorStoragePath)
            self.signer.save<@DAAM_V22.Creator>(<- creator!, to: DAAM_V22.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V22.Creator>(from: DAAM_V22.creatorStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_V22.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
<<<<<<< HEAD
            self.signer.link<&DAAM_V22.MetadataGenerator{DAAM_V22.MetadataGeneratorMint, DAAM_V22.MetadataGeneratorPublic}>(DAAM_V22.metadataPublicPath, target: DAAM_V22.metadataStoragePath)
            self.signer.save<@DAAM_V22.MetadataGenerator>(<- metadataGen, to: DAAM_V22.metadataStoragePath)
=======
            self.signer.link<&DAAM_V22.MetadataGenerator{DAAM_V22.MetadataGeneratorMint, DAAM_V22.MetadataGeneratorPublic}>(DAAM_V22.metadataPublicPath, target: DAAM_V22.metadataStoragePath)
            self.signer.save<@DAAM_V22.MetadataGenerator>(<- metadataGen, to: DAAM_V22.metadataStoragePath)
>>>>>>> 586a0096 (updated FUSD Address)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V22.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
<<<<<<< HEAD
            self.signer.save<@DAAM_V22.RequestGenerator>(<- requestGen, to: DAAM_V22.requestStoragePath)
=======
            self.signer.save<@DAAM_V22.RequestGenerator>(<- requestGen, to: DAAM_V22.requestStoragePath)
>>>>>>> 586a0096 (updated FUSD Address)
            destroy old_request

            log("You are now a DAAM_V22.Creator." )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }

    post { Profile.check(self.signer.address): "Account was not initialized" }
}