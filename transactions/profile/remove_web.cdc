// remove_web.cdc

import DAAM_Mainnet_Profile  from 0x192440c99cb17282

transaction(web: String) {
    let web  : String
    let user : &DAAMDAAM_Mainnet_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.web  = web
        self.user = signer.borrow<&DAAMDAAM_Mainnet_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
    }

    execute {
        self.user.removeWeb(self.web)
    }
}