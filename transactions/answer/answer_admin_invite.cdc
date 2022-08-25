// answer_admin_invite.cdc
// Answer the invitation to be an Admin.

import DAAM_V22.V22 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let admin <- DAAM_V22.V22.answerAdminInvite(newAdmin: self.signer, submit: self.submit)
        if admin != nil {
<<<<<<< HEAD
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V22.V22.adminStoragePath)
            self.signer.save<@DAAM_V22.Admin>(<- admin!, to: DAAM_V22.V22.adminStoragePath)
            let adminRef = self.signer.borrow<&DAAM_V22.Admin>(from: DAAM_V22.V22.adminStoragePath)!
=======
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V22.adminStoragePath)
            self.signer.save<@DAAM_V22.Admin>(<- admin!, to: DAAM_V22.adminStoragePath)
            let adminRef = self.signer.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V22.V22.requestStoragePath)
            let requestGen <-! adminRef.newRequestGenerator()
<<<<<<< HEAD
            self.signer.save<@DAAM_V22.RequestGenerator>(<- requestGen, to: DAAM_V22.V22.requestStoragePath)
=======
            self.signer.save<@DAAM_V22.RequestGenerator>(<- requestGen, to: DAAM_V22.requestStoragePath)
>>>>>>> 586a0096 (updated FUSD Address)
            destroy old_request
            
            log("You are now a DAAM_V22.V22.Admin: ".concat(self.signer.address.toString()) )
        } else {
            destroy admin
            log("Thank You for your consoderation.")
        }
    }
}
