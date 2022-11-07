// set_email.cdc

import DAAM_Mainnet_Profile from 0x192440c99cb17282

transaction(name: String?, at: String?, dot: String?) {
    let name : String?
    let at   : String?
    let dot  : String?
    let user : &DAAMDAAM_Mainnet_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.name = name == nil ? nil : name!.toLower()
        self.at   = at == nil ? nil   : at!.toLower()
        self.dot  = dot== nil ? nil   : dot!.toLower()
        self.user = signer.borrow<&DAAMDAAM_Mainnet_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
    }

    pre { (name==nil && at==nil && dot==nil) || (name!=nil && at!=nil && dot!=nil) }

    execute {
        self.user.setEmail(name: self.name, at: self.at, dot: self.dot)
    }
}