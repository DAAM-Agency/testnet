// set_about.cdc

import DAAM_Mainnet_Profile from 0x0bb80b2a4cb38cdf

transaction(about: String?) {
    let about : String?
    let user  : &DAAM_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.about = about
        self.user  = signer.borrow<&DAAM_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
    }

    execute {
        self.user.setAbout(self.about)
    }
}