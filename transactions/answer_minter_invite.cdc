// answer_minter_invite.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let minter  <- DAAM_V5.answerMinterInvite(minter: self.signer.address, submit: submit)

        if minter != nil && submit {
            self.signer.save<@DAAM_V5.Minter>(<- minter!, to: DAAM_V5.minterStoragePath)!
            self.signer.link<&DAAM_V5.Minter>(DAAM_V5.minterPrivatePath, target: DAAM_V5.minterStoragePath)!
            log("You are now a DAAM_V5.Minter: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
