// answer_admin_invite.cdc

import DAAM_NFT from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let daam: PublicAccount
    let adminCap: Capability<&DAAM_NFT.Admin{DAAM_NFT.InvitedAdmin}>
    let adminRef: &DAAM_NFT.Admin{DAAM_NFT.InvitedAdmin}
    let signer: AuthAccount
    
    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.daam = getAccount(0xfd43f9148d4b725d)
        self.adminCap = self.daam.getCapability<&DAAM_NFT.Admin{DAAM_NFT.InvitedAdmin}>(DAAM_NFT.adminPublicPath)
        self.adminRef = self.adminCap.borrow()! //?? panic("Could not borrow a reference to the Admin")
        self.signer = signer
    }

    execute {
        let admin  <- self.adminRef.answerAdminInvite(self.signer.address, submit)

        if admin != nil {
            self.signer.save(<- admin, to: DAAM_NFT.adminStoragePath)
            self.signer.link<&DAAM_NFT.Admin{DAAM_NFT.Founder}>(DAAM_NFT.adminPrivatePath, target: DAAM_NFT.adminStoragePath)
            log("You are now a D.A.A.M Admin")
        } else {
            destroy admin
        }

        if !submit { log("Well,... fuck you too !!!") }
    }
}
