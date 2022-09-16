// invite_minter.cdc
// Used for Admin to give Minter access.

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V23.Admin
    let newMinter : Address

    prepare(admin: AuthAccount) {
<<<<<<< HEAD
        self.admin     = admin.borrow<&DAAM_V23.Admin>(from: DAAM_V23.adminStoragePath)!
=======
        self.admin     = admin.borrow<&DAAM.Admin>(from: DAAM_V23.adminStoragePath)!
>>>>>>> tomerge
        self.newMinter = newMinter
    }

    pre { DAAM_V23.isMinter(newMinter) == nil : newMinter.toString().concat(" is already a Minter.") }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
