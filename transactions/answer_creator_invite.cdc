// answer_admin_invite.cdc

import DAAM from x51e2c02e69b53477

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let creator  <- DAAM.answerCreatorInvite(newCreator: self.signer.address, submit: submit)

        if creator != nil {
            let rh <- creator.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- rh, to: DAAM.requestStoragePath)
            self.signer.save<@DAAM.Creator>(<- creator, to: DAAM.creatorStoragePath)
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPublicPath, target: DAAM.requestStoragePath)!
            self.signer.link<&DAAM.Creator>(DAAM.creatorPrivatePath, target: DAAM.creatorStoragePath)!
            log("You are now a DAAM Creator: ".concat(self.signer.address.toString()) )
        } 

        if !submit { log("Thank You for your consideration.") }
    }
}
