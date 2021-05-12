// invite_artist.cdc

import DAAM from 0x045a1763c93006ca

transaction(artist: Address) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.inviteArtist(artist)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Artist Invited")
    }
}// transaction
