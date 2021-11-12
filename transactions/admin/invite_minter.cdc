// invite_minter.cdc
// Used for Admin to give Minter access.

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V5.Admin
    let newMinter : Address

<<<<<<< HEAD
    prepare(acct: AuthAccount) {
        self.admin     = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
=======
    prepare(admin: AuthAccount) {
        self.admin     = admin.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
>>>>>>> merge_dev
        self.newMinter = newMinter
    }

    pre { DAAM_V5.isMinter(newMinter) == nil : newMinter.toString().concat(" is already a Minter.") }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
