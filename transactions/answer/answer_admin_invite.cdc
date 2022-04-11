// answer_admin_invite.cdc
// Answer the invitation to be an Admin.

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let admin <- DAAM_V8.answerAdminInvite(newAdmin: self.signer, submit: self.submit)
        if admin != nil {
            self.signer.save<@DAAM_V8.Admin>(<- admin!, to: DAAM_V8.adminStoragePath)
            let adminRef = self.signer.borrow<&DAAM_V8.Admin>(from: DAAM_V8.adminStoragePath)!

            let requestGen <-! adminRef.newRequestGenerator()
            self.signer.save<@DAAM_V8.RequestGenerator>(<- requestGen, to: DAAM_V8.requestStoragePath)
            
            log("You are now a DAAM_V8.Admin: ".concat(self.signer.address.toString()) )
        } else {
            destroy admin
            log("Thank You for your consoderation.")
        }
    }
}
