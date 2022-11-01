// remove_social.cdc

import DAAM_Profile from 0x192440c99cb17282

transaction(social: String ) {
    let social : String
    let user   : &DAAM_Profile.User

    prepare(signer: AuthAccount) {
        self.social = social
        self.user   = signer.borrow<&DAAM_Profile.User>(from: DAAM_Profile.storagePath)!
    }

    execute {
        self.user.removeSocial(self.social)
    }
}