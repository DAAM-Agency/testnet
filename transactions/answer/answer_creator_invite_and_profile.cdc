// answer_creator_invite.cdc
// Answer the invitation to be a Creator.

import DAAM_Profile from 0x0bb80b2a4cb38cdf
import DAAM_Mainnet         from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        if !DAAM_Profile.check(self.signer.address) {
            let daamProfile = DAAM_Profile.createProfile()
            self.signer.save(<- daamProfile, to: DAAM_Profile.storagePath)
            self.signer.link<&DAAM_Profile.User{DAAM_Profile.Public}>(DAAM_Profile.publicPath, target: DAAM_Profile.storagePath)
        }

        let creator <- DAAM_Mainnet.answerCreatorInvite(newCreator: self.signer, submit: self.submit)
        if creator != nil {
            let old_creator <- self.signer.load<@AnyResource>(from: DAAM_Mainnet.creatorStoragePath)
            self.signer.save<@DAAM_Mainnet.Creator>(<- creator!, to: DAAM_Mainnet.creatorStoragePath)
            let creatorRef = self.signer.borrow<&DAAM_Mainnet.Creator>(from: DAAM_Mainnet.creatorStoragePath)!
            destroy old_creator

            let old_mg <- self.signer.load<@AnyResource>(from: DAAM_Mainnet.metadataStoragePath)
            let metadataGen <- creatorRef.newMetadataGenerator()
            self.signer.link<&DAAM_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorMint, DAAM_Mainnet.MetadataGeneratorPublic}>(DAAM_Mainnet.metadataPublicPath, target: DAAM_Mainnet.metadataStoragePath)
            self.signer.save<@DAAM_Mainnet.MetadataGenerator>(<- metadataGen, to: DAAM_Mainnet.metadataStoragePath)
            destroy old_mg

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_Mainnet.requestStoragePath)
            let requestGen  <- creatorRef.newRequestGenerator()
            self.signer.save<@DAAM_Mainnet.RequestGenerator>(<- requestGen, to: DAAM_Mainnet.requestStoragePath)
            destroy old_request

            log("You are now a DAAM_Mainnet.Creator." )        
        } else {
            destroy creator
            log("Thank You for your Consoderation.")
        }
    }

    post { DAAM_Profile.check(self.signer.address): "Account was not initialized" }
}