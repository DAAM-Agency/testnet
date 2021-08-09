// answer_creator_invite.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM.answerCreatorInvite(newCreator: self.signer.address, submit: submit)

        if creator != nil &7 submit {
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
