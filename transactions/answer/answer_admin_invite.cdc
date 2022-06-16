// answer_admin_invite.cdc
// Answer the invitation to be an Admin.

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V14

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
<<<<<<< HEAD
        let admin <- DAAM_V10.answerAdminInvite(newAdmin: self.signer, submit: self.submit)
        if admin != nil {
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V10.adminStoragePath)
            self.signer.save<@DAAM_V10.Admin>(<- admin!, to: DAAM_V10.adminStoragePath)
            let adminRef = self.signer.borrow<&DAAM_V10.Admin>(from: DAAM_V10.adminStoragePath)!
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V10.requestStoragePath)
            let requestGen <-! adminRef.newRequestGenerator()
            self.signer.save<@DAAM_V10.RequestGenerator>(<- requestGen, to: DAAM_V10.requestStoragePath)
            destroy old_request
            
            log("You are now a DAAM_V10.Admin: ".concat(self.signer.address.toString()) )
=======
        let admin <- DAAM_V14.answerAdminInvite(newAdmin: self.signer, submit: self.submit)
        if admin != nil {
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_V14.adminStoragePath)
            self.signer.save<@DAAM_V14.Admin>(<- admin!, to: DAAM_V14.adminStoragePath)
            let adminRef = self.signer.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath)!
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_V14.requestStoragePath)
            let requestGen <-! adminRef.newRequestGenerator()
            self.signer.save<@DAAM_V14.RequestGenerator>(<- requestGen, to: DAAM_V14.requestStoragePath)
            destroy old_request
            
            log("You are now a DAAM_V14.Admin: ".concat(self.signer.address.toString()) )
>>>>>>> DAAM_V14
        } else {
            destroy admin
            log("Thank You for your consoderation.")
        }
    }
}
