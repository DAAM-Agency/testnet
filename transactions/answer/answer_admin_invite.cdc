// answer_admin_invite.cdc
// Answer the invitation to be an Admin.

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let admin <- DAAM.answerAdminInvite(newAdmin: self.signer, submit: self.submit)
        if admin != nil {
            self.signer.save<@DAAM.Admin>(<- admin!, to: DAAM.adminStoragePath)
            let adminRef = self.signer.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!

            let requestGen <-! adminRef.newRequestGenerator()
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)
            
            log("You are now a DAAM Admin: ".concat(self.signer.address.toString()) )
        } else {
            destroy admin
            log("Thank You for your consoderation.")
        }
    }
}
