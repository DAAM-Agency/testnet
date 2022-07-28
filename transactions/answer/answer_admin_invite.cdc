// answer_admin_invite.cdc
// Answer the invitation to be an Admin.

import DAAM_V20 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let admin <- DAAM_V20.answerAdminInvite(newAdmin: self.signer, submit: self.submit)
        if admin != nil {
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V20.adminStoragePath)
            self.signer.save<@DAAM_V20.Admin>(<- admin!, to: DAAM_V20.adminStoragePath)
            let adminRef = self.signer.borrow<&DAAM_V20.Admin>(from: DAAM_V20.adminStoragePath)!
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V20.requestStoragePath)
            let requestGen <-! adminRef.newRequestGenerator()
            self.signer.save<@DAAM_V20.RequestGenerator>(<- requestGen, to: DAAM_V20.requestStoragePath)
            destroy old_request
            
            log("You are now a DAAM_V20.Admin: ".concat(self.signer.address.toString()) )
        } else {
            destroy admin
            log("Thank You for your consoderation.")
        }
    }
}
