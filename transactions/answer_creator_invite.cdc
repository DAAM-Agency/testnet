// answer_creator_invite.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM.answerCreatorInvite(newCreator: self.signer.address, submit: submit)

        if creator != nil && submit {
            self.signer.save<@DAAM.Creator>(<- creator!, to: DAAM.creatorStoragePath)!
            self.signer.link<&DAAM.Creator>(DAAM.creatorPrivatePath, target: DAAM.creatorStoragePath)!
            let creatorRef = self.signer.borrow<&DAAM.Creator>(from: DAAM.creatorStoragePath)!
            let requestGen <- creatorRef.newRequestGenerator()!
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)!
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPrivatePath, target: DAAM.requestStoragePath)!
            log("You are now a DAAM Creator: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
