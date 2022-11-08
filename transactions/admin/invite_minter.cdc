// invite_minter.cdc
// Used for Admin to give Minter access.

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_Mainnet.Admin
    let newMinter : Address

    prepare(admin: AuthAccount) {
        self.admin     = admin.borrow<&DAAM_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
        self.newMinter = newMinter
    }

    pre { DAAM_Mainnet.isMinter(newMinter) == nil : newMinter.toString().concat(" is already a Minter.") }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
