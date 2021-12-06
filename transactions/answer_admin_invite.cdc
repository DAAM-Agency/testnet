// answer_admin_invite.cdc
// Answer the invitation to be an Admin.

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let admin  <- DAAM_V7.answerAdminInvite(newAdmin: self.signer, submit: submit)

        if admin != nil && submit {
            self.signer.save<@DAAM_V7.Admin>(<- admin!, to: DAAM_V7.adminStoragePath)!
            self.signer.link<&DAAM_V7.Admin>(DAAM_V7.adminPrivatePath, target: DAAM_V7.adminStoragePath)!
            let adminRef = self.signer.borrow<&DAAM_V7.Admin>(from: DAAM_V7.adminStoragePath)!

            let requestGen <- adminRef.newRequestGenerator()!
            self.signer.save<@DAAM_V7.RequestGenerator>(<- requestGen, to: DAAM_V7.requestStoragePath)!
            self.signer.link<&DAAM_V7.RequestGenerator>(DAAM_V7.requestPrivatePath, target: DAAM_V7.requestStoragePath)!
            
            log("You are now a DAAM_V7 Admin: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
