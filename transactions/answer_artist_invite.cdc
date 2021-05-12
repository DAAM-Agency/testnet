// answer_artist_invite.cdc

import DAAM from 0x045a1763c93006ca

transaction(submit: Bool) {
    let daam: PublicAccount
    let adminCap: Capability<&DAAM.Admin{DAAM.InvitedArtist}>
    let adminRef: &DAAM.Admin{DAAM.InvitedArtist}
    let signer: AuthAccount
    
    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.daam = getAccount(0x045a1763c93006ca)
        self.adminCap = self.daam.getCapability<&DAAM.Admin{DAAM.InvitedArtist}>(DAAM.adminPublicPath)
        self.adminRef = self.adminCap.borrow()!
        self.signer = signer
    }
    
    execute {
        let artist <- self.adminRef.answerArtistInvite(self.signer.address, submit)

        if artist != nil {
            self.signer.save(<- artist, to: DAAM.artistStoragePath)
            self.signer.link<&DAAM.Artist>(DAAM.artistPrivatePath, target: DAAM.artistStoragePath)
            log("You are now a D.A.A.M Artist")
        } else {
            destroy artist
        }

        if !submit { log("Well,... fuck you too !!!") }
    }
}
