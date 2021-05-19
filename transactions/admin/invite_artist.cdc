// invite_artist.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(artist: Address) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.inviteArtist(artist)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Artist Invited")
    }
}// transaction
