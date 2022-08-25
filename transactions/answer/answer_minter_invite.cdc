// answer_minter_invite.cdc
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit
    }

    execute {
        let minter <- DAAM_V22.answerMinterInvite(newMinter: self.signer, submit: self.submit)
        if minter != nil {
            let old_minter <- self.signer.load<@AnyResource>(from: DAAM_V22.minterStoragePath)
            self.signer.save<@DAAM.Minter>(<- minter!, to: DAAM_V22.minterStoragePath)
            destroy old_minter
            log("You are now a DAAM_V22.Minter")
        } else {
            destroy minter
            log("Thank You for your consoderation.")
        }
    }
}
