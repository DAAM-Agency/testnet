// invite_artist.cdc

import MarketPalace from 0x045a1763c93006ca

transaction(artist: Address) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@MarketPalace.Admin{MarketPalace.Founder}>(from: MarketPalace.adminStoragePath)!
        admin.inviteArtist(artist)
        acct.save<@MarketPalace.Admin{MarketPalace.Founder}>(<- admin, to: MarketPalace.adminStoragePath)
        log("Artist Invited")
    }
}// transaction
