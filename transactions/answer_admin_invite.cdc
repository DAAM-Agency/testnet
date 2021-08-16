// answer_admin_invite.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let admin  <- DAAM_V3.answerAdminInvite(newAdmin: self.signer, submit: submit)

        if admin != nil && submit {
            self.signer.save<@DAAM_V3.Admin{DAAM_V3.Founder}>(<- admin!, to: DAAM_V3.adminStoragePath)!
            self.signer.link<&DAAM_V3.Admin{DAAM_V3.Founder}>(DAAM_V3.adminPrivatePath, target: DAAM_V3.adminStoragePath)!
            let adminRef = self.signer.borrow<&DAAM_V3.Admin>(from: DAAM_V3.adminStoragePath)!
            let requestGen <- adminRef.newRequestGenerator()!
            self.signer.save<@DAAM_V3.RequestGenerator>(<- requestGen, to: DAAM_V3.requestStoragePath)!
            self.signer.link<&DAAM_V3.RequestGenerator>(DAAM_V3.requestPrivatePath, target: DAAM_V3.requestStoragePath)!
            log("You are now a DAAM_V3.Admin: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
