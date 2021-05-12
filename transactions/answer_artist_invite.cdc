// answer_artist_invite.cdc

import DAAM from 0x045a1763c93006ca

transaction(submit: Bool) {
    
    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        let daam = getAccount(0x045a1763c93006ca)
        let adminCap = daam.getCapability<&DAAM.Admin{DAAM.InvitedArtist}>(DAAM.adminPublicPath)
        let adminRef = adminCap.borrow()! // ?? panic("Could not borrow a reference to the Admin")
        let artist <- adminRef.answerArtistInvite(signer.address, submit)

        if artist != nil {
            signer.save(<- artist, to: DAAM.artistStoragePath)
            signer.link<&DAAM.Artist>(DAAM.artistPublicPath, target: DAAM.artistStoragePath)
            log("You are now a D.A.A.M Artist")
        } else {
            destroy artist
        }

        if !submit { log("Well,... fuck you too !!!") }
    }
}
