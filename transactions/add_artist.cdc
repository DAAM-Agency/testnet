// add_artist.cdc

import DAAM from 0x045a1763c93006ca

transaction(artist: Address) {  
    let adminCap: Capability<&DAAM.Admin>
    let adminRef: &DAAM.Admin
    prepare(acct: AuthAccount) {
        self.adminCap = acct.getCapability<&DAAM.Admin>(DAAM.adminPublicPath)
        self.adminRef = self.adminCap.borrow() ?? panic("You're no D.A.A.M Admin!!!")
        //self.adminRef.addArtist(artist)
        log("Artist Added")
    }
}// transaction
