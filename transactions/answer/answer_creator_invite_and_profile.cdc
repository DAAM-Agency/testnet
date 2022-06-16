// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

<<<<<<< HEAD
import Profile from 0xe223d8a629e49c68
import DAAM_V10    from 0xa4ad5ea5c0bd2fba
=======
import Profile from 0xba1132bc08f82fe2
import DAAM_V14    from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V14

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
        let creator <- DAAM_V10.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_V10.creatorStoragePath)
            self.signer.save<@DAAM_V10.Creator>(<- creator!, to: DAAM_V10.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_V10.Creator>(from: DAAM_V10.creatorStoragePath)!
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_V10.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_V10.MetadataGenerator{DAAM_V10.MetadataGeneratorMint, DAAM_V10.MetadataGeneratorPublic}>(DAAM_V10.metadataPublicPath, target: DAAM_V10.metadataStoragePath)
            self.signer.save<@DAAM_V10.MetadataGenerator>(<- metadataGen, to: DAAM_V10.metadataStoragePath)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V10.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_V10.RequestGenerator>(<- requestGen, to: DAAM_V10.requestStoragePath)
            destroy old_request

            log("You are now a DAAM_V10.Creator." )        
=======
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
>>>>>>> DAAM_V14
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }

    post { Profile.check(self.signer.address): "Account was not initialized" }
}