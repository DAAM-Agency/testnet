// add_artist.cdc

import Profile from 0xf8d6e0586b0a20c7
import DAAM from 0xf8d6e0586b0a20c7

transaction(artist: Address) {  
    //let adminRef: &DAAM
    prepare(acct: AuthAccount) {
        //self.adminRef = acct.borrow<&TopShot.Admin>(from: /storage/TopShotAdmin) ?? panic("You're no D.A.A.M Admin!!!")
        DAAM.addArtist(artist)
    }
}// transaction
