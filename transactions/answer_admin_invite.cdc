// answer_admin_invite.cdc

import DAAM from x51e2c02e69b53477

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let admin  <- DAAM.answerAdminInvite(newAdmin: self.signer.address, submit: submit)

        if admin != nil {
            self.signer.save(<- admin, to: DAAM.adminStoragePath)
            self.signer.link<&DAAM.Admin{DAAM.Founder}>(DAAM.adminPrivatePath, target: DAAM.adminStoragePath)
            log("You are now a DAAM Admin: ".concat(self.signer.address.toString()) )
        } else {
            destroy admin
        }

        if !submit { log("Well,... fuck you too !!!") }
    }
}
