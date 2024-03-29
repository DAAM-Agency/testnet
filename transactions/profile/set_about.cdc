// set_about.cdc

import DAAM_Profile from 0x0bb80b2a4cb38cdf

transaction(about: String?) {
    let about : String?
    let user  : &DAAM_Profile.User

    prepare(signer: AuthAccount) {
        self.about = about
        self.user  = signer.borrow<&DAAM_Profile.User>(from: DAAM_Profile.storagePath)!
    }

    execute {
        self.user.setAbout(self.about)
    }
}