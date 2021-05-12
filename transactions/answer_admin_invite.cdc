// answer_admin_invite.cdc

import MarketPalace from 0x045a1763c93006ca

transaction(submit: Bool) {
    let daam: PublicAccount
    let adminCap: Capability<&MarketPalace.Admin{MarketPalace.InvitedAdmin}>
    let adminRef: &MarketPalace.Admin{MarketPalace.InvitedAdmin}
    let signer: AuthAccount
    
    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.daam = getAccount(0x045a1763c93006ca)
        self.adminCap = self.daam.getCapability<&MarketPalace.Admin{MarketPalace.InvitedAdmin}>(MarketPalace.adminPublicPath)
        self.adminRef = self.adminCap.borrow()! //?? panic("Could not borrow a reference to the Admin")
        self.signer = signer
    }

    execute {
        let admin  <- self.adminRef.answerAdminInvite(self.signer.address, submit)

        if admin != nil {
            self.signer.save(<- admin, to: MarketPalace.adminStoragePath)
            self.signer.link<&MarketPalace.Admin{MarketPalace.Founder}>(MarketPalace.adminPrivatePath, target: MarketPalace.adminStoragePath)
            log("You are now a D.A.A.M Admin")
        } else {
            destroy admin
        }

        if !submit { log("Well,... fuck you too !!!") }
    }
}
