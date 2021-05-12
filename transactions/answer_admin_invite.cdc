// answer_admin_invite.cdc

import DAAM from 0x045a1763c93006ca

transaction(submit: Bool) {
    
    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        let daam = getAccount(0x045a1763c93006ca)
        let adminCap = daam.getCapability<&DAAM.Admin{DAAM.InvitedAdmin}>(DAAM.adminPublicPath)
        let adminRef = adminCap.borrow()! //?? panic("Could not borrow a reference to the Admin")
        let admin  <- adminRef.answerAdminInvite(signer.address, submit)

        if admin != nil {
            signer.save(<- admin, to: DAAM.adminStoragePath)
            signer.link<&DAAM.Admin{DAAM.Founder}>(DAAM.adminPublicPath, target: DAAM.adminStoragePath)
            log("You are now a D.A.A.M Admin")
        } else {
            destroy admin
        }

        if !submit { log("Well,... fuck you too !!!") }
    }
}
