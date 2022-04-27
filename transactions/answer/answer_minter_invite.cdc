// answer_minter_invite.cdc
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit
    }

    execute {
        let minter <- DAAM.answerMinterInvite(newMinter: self.signer, submit: self.submit)
        if minter != nil {
            let old_minter <- self.signer.load<@AnyResource>(from: DAAM.minterStoragePath)
            self.signer.save<@DAAM.Minter>(<- minter!, to: DAAM.minterStoragePath)
            destroy old_minter
            log("You are now a DAAM.Minter")
        } else {
            destroy minter
            log("Thank You for your consoderation.")
        }
    }
}
