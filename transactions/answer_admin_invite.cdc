// answer_admin_invite.cdc

import DAAM_V4 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let admin  <- DAAM_V4.answerAdminInvite(newAdmin: self.signer, submit: submit)

        if admin != nil && submit {
            self.signer.save<@DAAM_V4.Admin{DAAM_V4.Founder}>(<- admin!, to: DAAM_V4.adminStoragePath)!
            self.signer.link<&{DAAM_V4.Founder}>(DAAM_V4.adminPrivatePath, target: DAAM_V4.adminStoragePath)!
            let adminRef = self.signer.borrow<&{DAAM_V4.Founder}>(from: DAAM_V4.adminStoragePath)!

            let requestGen <- adminRef.newRequestGenerator()!
            self.signer.save<@DAAM_V4.RequestGenerator>(<- requestGen, to: DAAM_V4.requestStoragePath)!
            self.signer.link<&DAAM_V4.RequestGenerator>(DAAM_V4.requestPrivatePath, target: DAAM_V4.requestStoragePath)!
            
            log("You are now a DAAM_V4.Admin: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
