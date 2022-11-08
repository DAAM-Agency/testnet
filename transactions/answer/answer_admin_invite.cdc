// answer_admin_invite.cdc
// Answer the invitation to be an Admin.

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount
    let submit: Bool

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.submit = submit     
    }

    execute {
        let admin <- DAAM_Mainnet.answerAdminInvite(newAdmin: self.signer, submit: self.submit)
        if admin != nil {
            let old_admin <- self.signer.load<@AnyResource>(from: DAAM_Mainnet.adminStoragePath)
            self.signer.save<@DAAM_Mainnet.Admin>(<- admin!, to: DAAM_Mainnet.adminStoragePath)
            let adminRef = self.signer.borrow<&DAAM_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
            destroy old_admin

            let old_request <- self.signer.load<@AnyResource>(from: DAAM_Mainnet.requestStoragePath)
            let requestGen <-! adminRef.newRequestGenerator()
            self.signer.save<@DAAM_Mainnet.RequestGenerator>(<- requestGen, to: DAAM_Mainnet.requestStoragePath)
            destroy old_request
            
            log("You are now a DAAM_Mainnet.Admin: ".concat(self.signer.address.toString()) )
        } else {
            destroy admin
            log("Thank You for your consoderation.")
        }
    }
}
