// answer_minter_invite.cdc
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let minter <- DAAM.answerMinterInvite(minter: self.signer, submit: submit)
        if minter != nil {
            self.signer.save<@DAAM.Minter>(<- minter!, to: DAAM.minterStoragePath)
            log("You are now a DAAM Minter: ".concat(self.signer.address.toString()) )
        } else {
            destroy minter
            log("Thank You for your consoderation.")
        }
    }
}
