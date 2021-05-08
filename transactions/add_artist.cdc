// add_artist.cdc

import DAAM from 0x045a1763c93006ca

transaction() {  
    let admin: &DAAM.Admin
    prepare(acct: AuthAccount) {
        self.admin = acct.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath) ?? panic("You're no D.A.A.M Admin!!!")
        self.admin.addArtist(acct.address)
    }
}// transaction
