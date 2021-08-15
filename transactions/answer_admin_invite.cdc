// answer_admin_invite.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let admin  <- DAAM_V2.answerAdminInvite(newAdmin: self.signer, submit: submit)

        if admin != nil && submit {
            self.signer.save<@DAAM_V2.Admin{DAAM_V2.Founder}>(<- admin!, to: DAAM_V2.adminStoragePath)!
            self.signer.link<&DAAM_V2.Admin{DAAM_V2.Founder}>(DAAM_V2.adminPrivatePath, target: DAAM_V2.adminStoragePath)!
            let adminRef = self.signer.borrow<&DAAM_V2.Admin>(from: DAAM_V2.adminStoragePath)!
            let requestGen <- adminRef.newRequestGenerator()!
            self.signer.save<@DAAM_V2.RequestGenerator>(<- requestGen, to: DAAM_V2.requestStoragePath)!
            self.signer.link<&DAAM_V2.RequestGenerator>(DAAM_V2.requestPrivatePath, target: DAAM_V2.requestStoragePath)!
            log("You are now a DAAM_V2.Admin: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
