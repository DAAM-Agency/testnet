// answer_creator_invite.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM_V2.answerCreatorInvite(newCreator: self.signer.address, submit: submit)

        if creator != nil && submit {
            self.signer.save<@DAAM_V2.Creator>(<- creator!, to: DAAM_V2.creatorStoragePath)!
            self.signer.link<&DAAM_V2.Creator>(DAAM_V2.creatorPrivatePath, target: DAAM_V2.creatorStoragePath)!
            let creatorRef = self.signer.borrow<&DAAM_V2.Creator>(from: DAAM_V2.creatorStoragePath)!
            let requestGen <- creatorRef.newRequestGenerator()!
            self.signer.save<@DAAM_V2.RequestGenerator>(<- requestGen, to: DAAM_V2.requestStoragePath)!
            self.signer.link<&DAAM_V2.RequestGenerator>(DAAM_V2.requestPrivatePath, target: DAAM_V2.requestStoragePath)!
            log("You are now a DAAM_V2.Creator: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
