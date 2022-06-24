// answer_minter_invite.cdc
// Answer the invitation to be a Minter. Typically only for Auctions & Marketplaces

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit
    }

    execute {
<<<<<<< HEAD
        let minter <- DAAM_V14.answerMinterInvite(newMinter: self.signer, submit: self.submit)
        if minter != nil {
            let old_minter <- self.signer.load<@AnyResource>(from: DAAM_V14.minterStoragePath)
            self.signer.save<@DAAM_V14.Minter>(<- minter!, to: DAAM_V14.minterStoragePath)
            destroy old_minter
            log("You are now a DAAM_V14.Minter")
=======
        let minter <- DAAM_V15.answerMinterInvite(newMinter: self.signer, submit: self.submit)
        if minter != nil {
            let old_minter <- self.signer.load<@AnyResource>(from: DAAM_V15.minterStoragePath)
            self.signer.save<@DAAM_V15.Minter>(<- minter!, to: DAAM_V15.minterStoragePath)
            destroy old_minter
            log("You are now a DAAM_V15.Minter")
>>>>>>> DAAM_V15
        } else {
            destroy minter
            log("Thank You for your consoderation.")
        }
    }
}
