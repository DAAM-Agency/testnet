// answer_minter_invite.cdc
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    pre { submit : "Thank You for your consideration."}

    execute {
        let minter <-! DAAM.answerMinterInvite(minter: self.signer, submit: submit)

        self.signer.save<@DAAM.Minter>(<- minter!, to: DAAM.minterStoragePath)!
        self.signer.link<&DAAM.Minter>(DAAM.minterPrivatePath, target: DAAM.minterStoragePath)!
        log("You are now a DAAM Minter: ".concat(self.signer.address.toString()) )
    }
}
