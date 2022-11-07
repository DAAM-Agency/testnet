// add_social.cdc

import DAAM_Mainnet_Profile from 0x192440c99cb17282

transaction(social: {String : String} ) {
    let social : {String : String}
    let user   : &DAAMDAAM_Mainnet_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.social = social
        self.user   = signer.borrow<&DAAMDAAM_Mainnet_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
    }

    execute {
        self.user.addSocial(self.social)
    }
}