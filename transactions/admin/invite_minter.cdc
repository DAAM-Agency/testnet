// invite_minter.cdc
// Used for Admin to give Minter access.

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM.Admin
    let newMinter : Address

    prepare(admin: AuthAccount) {
        self.admin     = admin.borrow<&DAAM.Admin>(from: DAAM_V22.adminStoragePath)!
        self.newMinter = newMinter
    }

    pre { DAAM_V22.isMinter(newMinter) == nil : newMinter.toString().concat(" is already a Minter.") }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
