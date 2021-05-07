// add_artist.cdc

import Profile from 0x192440c99cb17282
import DAAM from 0x045a1763c93006ca

transaction(artist: Address) {  
    //let adminRef: &DAAM
    prepare(acct: AuthAccount) {
        //self.adminRef = acct.borrow<&TopShot.Admin>(from: /storage/TopShotAdmin) ?? panic("You're no D.A.A.M Admin!!!")
        DAAM.addArtist(artist)
    }
}// transaction
