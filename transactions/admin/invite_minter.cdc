// invite_minter.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V1.Admin{DAAM_V1.Founder}
    let newMinter : Address

    prepare(acct: AuthAccount) {
        self.admin     = acct.borrow<&DAAM_V1.Admin{DAAM_V1.Founder}>(from: DAAM_V1.adminStoragePath)!
        self.newMinter = newMinter
    }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
