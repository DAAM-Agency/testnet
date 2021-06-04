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
            self.signer.save<@DAAM.Creator>(<- creator, to: DAAM.creatorStoragePath)
            self.signer.link<&DAAM.Creator>(DAAM.creatorPrivatePath, target: DAAM.creatorStoragePath)!
            log("You are now a DAAM Creator: ".concat(self.signer.address.toString()) )
        } else {
            destroy creator
        }

        if !submit { log("Well, ... why the fuck did you  bother ?!?") }
    }
}
