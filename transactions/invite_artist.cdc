// invite_artist.cdc

import DAAM_NFT from 0xfd43f9148d4b725d

transaction(artist: Address) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@DAAM_NFT.Admin{DAAM_NFT.Founder}>(from: DAAM_NFT.adminStoragePath)!
        admin.inviteArtist(artist)
        acct.save<@DAAM_NFT.Admin{DAAM_NFT.Founder}>(<- admin, to: DAAM_NFT.adminStoragePath)
        log("Artist Invited")
    }
}// transaction
