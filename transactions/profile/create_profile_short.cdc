// create_profile_short.cdc
// Used to create a DAAM_Profile. This is the same as create_profile.cdc but only name and email.

import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_Profile  from 0x0bb80b2a4cb38cdf
import DAAM_Mainnet  from 0xa4ad5ea5c0bd2fba

transaction(name: String, emailName: String?, emailAt:String?, emailDot: String?)
{
    let signer: AuthAccount
    let name  : String
    let emailName : String?
    let emailAt   : String?
    let emailDot  : String?

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.name   = name
        self.emailName  = emailName
        self.emailAt    = emailAt 
        self.emailDot   = emailDot
    }

    execute {
        let profile <- DAAM_Profile.createProfile(
            name:self.name, about:nil, description:nil, web:nil, social:nil, avatar:nil, heroImage:nil, notes:nil)

        profile.setEmail(name: self.emailName, at: self.emailAt, dot: self.emailDot)
        
        self.signer.save<@DAAM_Profile.User>(<-profile, to: DAAM_Profile.storagePath)
        self.signer.link<&DAAM_Profile.User{DAAM_Profile.Public}>(DAAM_Profile.publicPath, target: DAAM_Profile.storagePath)
        log("DAAM_Mainnet Profile Created: ".concat(self.signer.address.toString()))
    }
}
 