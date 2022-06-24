// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import Profile from 0xba1132bc08f82fe2
<<<<<<< HEAD
import DAAM_V14    from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V15    from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15

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

<<<<<<< HEAD
        let creator <- DAAM_V14.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V14.creatorStoragePath)
            self.signer.save<@DAAM_V14.Creator>(<- creator!, to: DAAM_V14.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V14.Creator>(from: DAAM_V14.creatorStoragePath)!
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_V14.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_V14.MetadataGenerator{DAAM_V14.MetadataGeneratorMint, DAAM_V14.MetadataGeneratorPublic}>(DAAM_V14.metadataPublicPath, target: DAAM_V14.metadataStoragePath)
            self.signer.save<@DAAM_V14.MetadataGenerator>(<- metadataGen, to: DAAM_V14.metadataStoragePath)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V14.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_V14.RequestGenerator>(<- requestGen, to: DAAM_V14.requestStoragePath)
            destroy old_request

            log("You are now a DAAM_V14.Creator." )        
=======
        let creator <- DAAM_V15.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V15.creatorStoragePath)
            self.signer.save<@DAAM_V15.Creator>(<- creator!, to: DAAM_V15.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V15.Creator>(from: DAAM_V15.creatorStoragePath)!
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_V15.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_V15.MetadataGenerator{DAAM_V15.MetadataGeneratorMint, DAAM_V15.MetadataGeneratorPublic}>(DAAM_V15.metadataPublicPath, target: DAAM_V15.metadataStoragePath)
            self.signer.save<@DAAM_V15.MetadataGenerator>(<- metadataGen, to: DAAM_V15.metadataStoragePath)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V15.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_V15.RequestGenerator>(<- requestGen, to: DAAM_V15.requestStoragePath)
            destroy old_request

            log("You are now a DAAM_V15.Creator." )        
>>>>>>> DAAM_V15
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }

    post { Profile.check(self.signer.address): "Account was not initialized" }
}