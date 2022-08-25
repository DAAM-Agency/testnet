// invite_minter.cdc
// Used for Admin to give Minter access.

import DAAM_V22.V22 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V22.Admin
    let newMinter : Address

    prepare(admin: AuthAccount) {
<<<<<<< HEAD
        self.admin     = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.V22.adminStoragePath)!
=======
        self.admin     = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
        self.newMinter = newMinter
    }

    pre { DAAM_V22.V22.isMinter(newMinter) == nil : newMinter.toString().concat(" is already a Minter.") }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
