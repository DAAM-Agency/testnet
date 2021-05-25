// answer_admin_invite.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.signer = signer
    }

    execute {
        let artist  <- DAAM.answerArtistInvite(newArtist: self.signer.address, submit: submit)

        if artist != nil {
            self.signer.save<@DAAM.Artist>(<- artist, to: DAAM.artistStoragePath)
            self.signer.link<&DAAM.Artist>(DAAM.artistPublicPath, target: DAAM.artistStoragePath)!
            log("You are now a DAAM Artist: ".concat(self.signer.address.toString()) )
        } else {
            destroy artist
        }

        if !submit { log("Well, ... why the fuck did you  bother ?!?") }
    }
}
