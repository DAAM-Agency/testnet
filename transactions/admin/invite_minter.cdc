// invite_minter.cdc
// Used for Admin to give Minter access.

import DAAM_V8.V8.V8_V8.. from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V8.V8..Admin
    let newMinter : Address

    prepare(admin: AuthAccount) {
        self.admin     = admin.borrow<&DAAM_V8.V8..Admin>(from: DAAM_V8.V8..adminStoragePath)!
        self.newMinter = newMinter
    }

    pre { DAAM_V8.V8..isMinter(newMinter) == nil : newMinter.toString().concat(" is already a Minter.") }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
