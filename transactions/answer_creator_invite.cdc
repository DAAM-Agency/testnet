// answer_creator_invite.cdc

import DAAM_V3.V2 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM_V3.answerCreatorInvite(newCreator: self.signer.address, submit: submit)

        if creator != nil && submit {
            self.signer.save<@DAAM_V3.Creator>(<- creator!, to: DAAM_V3.creatorStoragePath)!
            self.signer.link<&DAAM_V3.Creator>(DAAM_V3.creatorPrivatePath, target: DAAM_V3.creatorStoragePath)!
            let creatorRef = self.signer.borrow<&DAAM_V3.Creator>(from: DAAM_V3.creatorStoragePath)!
            let requestGen <- creatorRef.newRequestGenerator()!
            self.signer.save<@DAAM_V3.RequestGenerator>(<- requestGen, to: DAAM_V3.requestStoragePath)!
            self.signer.link<&DAAM_V3.RequestGenerator>(DAAM_V3.requestPrivatePath, target: DAAM_V3.requestStoragePath)!
            log("You are now a DAAM_V3.Creator: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
