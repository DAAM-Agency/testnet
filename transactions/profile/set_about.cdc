// set_about.cdc

import DAAM_Mainnet_Profile from 0x192440c99cb17282

transaction(about: String?) {
    let about : String?
    let user  : &DAAMDAAM_Mainnet_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.about = about
        self.user  = signer.borrow<&DAAMDAAM_Mainnet_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
    }

    execute {
        self.user.setAbout(self.about)
    }
}