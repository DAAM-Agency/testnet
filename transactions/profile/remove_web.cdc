// remove_web.cdc

import DAAM_Profile  from 0x0bb80b2a4cb38cdf

transaction(web: String) {
    let web  : String
    let user : &DAAM_Profile.User

    prepare(signer: AuthAccount) {
        self.web  = web
        self.user = signer.borrow<&DAAM_Profile.User>(from: DAAM_Profile.storagePath)!
    }

    execute {
        self.user.removeWeb(self.web)
    }
}