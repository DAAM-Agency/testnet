// add_artist.cdc

import DAAM from 0x045a1763c93006ca

transaction() {  
    //let adminRef: &DAAM
    prepare(acct: AuthAccount) {
        //self.adminRef = acct.borrow<&TopShot.Admin>(from: /storage/TopShotAdmin) ?? panic("You're no D.A.A.M Admin!!!")
        DAAM.addArtist(acct.address)
    }
}// transaction
