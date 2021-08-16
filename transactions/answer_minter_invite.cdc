// answer_minter_invite.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let minter  <- DAAM_V3.answerMinterInvite(minter: self.signer.address, submit: submit)

        if minter != nil && submit {
            self.signer.save<@DAAM_V3.Minter>(<- minter!, to: DAAM_V3.minterStoragePath)!
            self.signer.link<&DAAM_V3.Minter>(DAAM_V3.minterPrivatePath, target: DAAM_V3.minterStoragePath)!
            log("You are now a DAAM_V3.Minter: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
