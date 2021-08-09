// invite_minter.cdc

import DAAM from 0xfd43f9148d4b725d

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
