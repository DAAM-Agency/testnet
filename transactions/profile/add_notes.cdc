// add_notes.cdc

import DAAM_Mainnet_Profile from 0x192440c99cb17282

transaction(notes: {String : String} ) {
    let notes : {String : String}
    let user   : &DAAMDAAM_Mainnet_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.notes = notes
        self.user   = signer.borrow<&DAAMDAAM_Mainnet_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
    }

    execute {
        self.user.addNotes(self.notes)
    }
}