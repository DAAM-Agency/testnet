// set_description.cdc

import DAAM_Mainnet_Profile from 0x192440c99cb17282

transaction(description: String?) {
    let description : String?
    let user  : &DAAMDAAM_Mainnet_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.description = description
        self.user        = signer.borrow<&DAAMDAAM_Mainnet_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
    }

    execute {
        self.user.setDescription(self.description)
    }
}
 