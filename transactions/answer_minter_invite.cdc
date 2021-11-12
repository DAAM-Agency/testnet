// answer_minter_invite.cdc
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let minter  <- DAAM_V6.answerMinterInvite(minter: self.signer, submit: submit)

        if minter != nil && submit {
            self.signer.save<@DAAM_V6.Minter>(<- minter!, to: DAAM_V6.minterStoragePath)!
            self.signer.link<&DAAM_V6.Minter>(DAAM_V6.minterPrivatePath, target: DAAM_V6.minterStoragePath)!
            log("You are now a DAAM_V6 Minter: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
