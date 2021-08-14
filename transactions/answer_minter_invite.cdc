// answer_minter_invite.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let minter  <- DAAM.answerMinterInvite(minter: self.signer.address, submit: submit)

        if minter != nil && submit {
            self.signer.save<@DAAM.Minter>(<- minter!, to: DAAM.minterStoragePath)!
            self.signer.link<&DAAM.Minter>(DAAM.minterPrivatePath, target: DAAM.minterStoragePath)!
            log("You are now a DAAM Minter: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}