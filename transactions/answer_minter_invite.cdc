// answer_minter_invite.cdc

import DAAM_V4 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let minter  <- DAAM_V4.answerMinterInvite(minter: self.signer.address, submit: submit)

        if minter != nil && submit {
            self.signer.save<@DAAM_V4.Minter>(<- minter!, to: DAAM_V4.minterStoragePath)!
            self.signer.link<&DAAM_V4.Minter>(DAAM_V4.minterPrivatePath, target: DAAM_V4.minterStoragePath)!
            log("You are now a DAAM_V4.Minter: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
