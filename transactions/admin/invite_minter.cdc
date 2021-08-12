// invite_minter.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin: &DAAM.Admin{DAAM.Founder}

    prepare(acct: AuthAccount) {
        self.admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
    }

    execute {
        self.admin.inviteMinter(newMinter)
        log("Minter Invited")
    }
}
