// answer_admin_invite.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let daam: PublicAccount
    let adminCap: Capability<&DAAM.Admin{DAAM.InvitedAdmin}>
    let adminRef: &DAAM.Admin{DAAM.InvitedAdmin}
    let signer: AuthAccount
    
    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.daam = getAccount(0xfd43f9148d4b725d)
        self.adminCap = self.daam.getCapability<&DAAM.Admin{DAAM.InvitedAdmin}>(DAAM.adminPublicPath)
        self.adminRef = self.adminCap.borrow()! //?? panic("Could not borrow a reference to the Admin")
        self.signer = signer
    }

    execute {
        let admin  <- self.adminRef.answerAdminInvite(self.signer.address, submit)

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
