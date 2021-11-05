// invite_minter.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V3.AdminDAAM_V3.Admin
    let newMinter : Address

    prepare(acct: AuthAccount) {
        self.admin     = acct.borrow<&DAAM_V3.AdminDAAM_V3.Admin>(from: DAAM_V3.adminStoragePath)!
        self.newMinter = newMinter
    }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
