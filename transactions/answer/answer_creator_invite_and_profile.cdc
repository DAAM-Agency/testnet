// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import Profile from 0xba1132bc08f82fe2
import DAAM_V23    from 0xa4ad5ea5c0bd2fba

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

        let creator <- DAAM_V23.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V23.creatorStoragePath)
            self.signer.save<@DAAM_V23.Creator>(<- creator!, to: DAAM_V23.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V23.Creator>(from: DAAM_V23.creatorStoragePath)!
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_V23.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_V23.MetadataGenerator{DAAM_V23.MetadataGeneratorMint, DAAM_V23.MetadataGeneratorPublic}>(DAAM_V23.metadataPublicPath, target: DAAM_V23.metadataStoragePath)
            self.signer.save<@DAAM_V23.MetadataGenerator>(<- metadataGen, to: DAAM_V23.metadataStoragePath)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V23.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_V23.RequestGenerator>(<- requestGen, to: DAAM_V23.requestStoragePath)
            destroy old_request

            log("You are now a DAAM_V23.Creator." )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }

    post { Profile.check(self.signer.address): "Account was not initialized" }
}