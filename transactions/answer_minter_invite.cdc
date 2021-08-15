// answer_minter_invite.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let minter  <- DAAM_V1.answerMinterInvite(minter: self.signer.address, submit: submit)

        if minter != nil && submit {
            self.signer.save<@DAAM_V1.Minter>(<- minter!, to: DAAM_V1.minterStoragePath)!
            self.signer.link<&DAAM_V1.Minter>(DAAM_V1.minterPrivatePath, target: DAAM_V1.minterStoragePath)!
            log("You are now a DAAM_V1 Minter: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
