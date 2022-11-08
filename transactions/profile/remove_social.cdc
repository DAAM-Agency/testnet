// remove_social.cdc

import DAAM_Mainnet_Profile from 0x0bb80b2a4cb38cdf

transaction(social: String ) {
    let social : String
    let user   : &DAAM_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.social = social
        self.user   = signer.borrow<&DAAM_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
    }

    execute {
        self.user.removeSocial(self.social)
    }
}