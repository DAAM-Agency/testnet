// answer_admin_invite.cdc
// Answer the invitation to be an Admin.

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let admin  <- DAAM_V6.answerAdminInvite(newAdmin: self.signer, submit: submit)

        if admin != nil && submit {
            self.signer.save<@DAAM_V6.Admin>(<- admin!, to: DAAM_V6.adminStoragePath)!
            self.signer.link<&DAAM_V6.Admin>(DAAM_V6.adminPrivatePath, target: DAAM_V6.adminStoragePath)!
            let adminRef = self.signer.borrow<&DAAM_V6.Admin>(from: DAAM_V6.adminStoragePath)!

            let requestGen <- adminRef.newRequestGenerator()!
            self.signer.save<@DAAM_V6.RequestGenerator>(<- requestGen, to: DAAM_V6.requestStoragePath)!
            self.signer.link<&DAAM_V6.RequestGenerator>(DAAM_V6.requestPrivatePath, target: DAAM_V6.requestStoragePath)!
            
            log("You are now a DAAM_V6 Admin: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
