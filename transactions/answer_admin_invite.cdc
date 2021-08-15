// answer_admin_invite.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let admin  <- DAAM_V1.answerAdminInvite(newAdmin: self.signer, submit: submit)

        if admin != nil && submit {
            self.signer.save<@DAAM_V1.Admin{DAAM_V1.Founder}>(<- admin!, to: DAAM_V1.adminStoragePath)!
            self.signer.link<&DAAM_V1.Admin{DAAM_V1.Founder}>(DAAM_V1.adminPrivatePath, target: DAAM_V1.adminStoragePath)!
            let adminRef = self.signer.borrow<&DAAM_V1.Admin>(from: DAAM_V1.adminStoragePath)!
            let requestGen <- adminRef.newRequestGenerator()!
            self.signer.save<@DAAM_V1.RequestGenerator>(<- requestGen, to: DAAM_V1.requestStoragePath)!
            self.signer.link<&DAAM_V1.RequestGenerator>(DAAM_V1.requestPrivatePath, target: DAAM_V1.requestStoragePath)!
            log("You are now a DAAM_V1 Admin: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
