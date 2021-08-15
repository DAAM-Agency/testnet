// answer_admin_invite.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let admin  <- DAAM.answerAdminInvite(newAdmin: self.signer, submit: submit)

        if admin != nil && submit {
            self.signer.save<@DAAM.Admin{DAAM.Founder}>(<- admin!, to: DAAM.adminStoragePath)!
            self.signer.link<&DAAM.Admin{DAAM.Founder}>(DAAM.adminPrivatePath, target: DAAM.adminStoragePath)!
            let adminRef = self.signer.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
            let requestGen <- adminRef.newRequestGenerator()!
            self.signer.save<@DAAM.RequestGenerator>(<- requestGen, to: DAAM.requestStoragePath)!
            self.signer.link<&DAAM.RequestGenerator>(DAAM.requestPrivatePath, target: DAAM.requestStoragePath)!
            log("You are now a DAAM Admin: ".concat(self.signer.address.toString()) )
        }
        if !submit { log("Thank You for your consideration.") }
    }
}
