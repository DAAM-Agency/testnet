// answer_creator_invite.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM_V1.answerCreatorInvite(newCreator: self.signer.address, submit: submit)

        if creator != nil && submit {
            self.signer.save<@DAAM_V1.Creator>(<- creator!, to: DAAM_V1.creatorStoragePath)!
            self.signer.link<&DAAM_V1.Creator>(DAAM_V1.creatorPrivatePath, target: DAAM_V1.creatorStoragePath)!
            let creatorRef = self.signer.borrow<&DAAM_V1.Creator>(from: DAAM_V1.creatorStoragePath)!
            let requestGen <- creatorRef.newRequestGenerator()!
            self.signer.save<@DAAM_V1.RequestGenerator>(<- requestGen, to: DAAM_V1.requestStoragePath)!
            self.signer.link<&DAAM_V1.RequestGenerator>(DAAM_V1.requestPrivatePath, target: DAAM_V1.requestStoragePath)!
            log("You are now a DAAM_V1 Creator: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
