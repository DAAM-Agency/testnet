// remove_notes.cdc

import DAAM_Mainnet_Profile from 0x0bb80b2a4cb38cdf

transaction(notes: String ) {
    let notes : String
    let user   : &DAAM_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.notes = notes
        self.user   = signer.borrow<&DAAM_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
    }

    execute {
        self.user.removeNotes(self.notes)
    }
}