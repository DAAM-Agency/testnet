// invite_minter.cdc

import DAAM_V3.V2 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V3.Admin{DAAM_V3.Founder}
    let newMinter : Address

    prepare(acct: AuthAccount) {
        self.admin     = acct.borrow<&DAAM_V3.Admin{DAAM_V3.Founder}>(from: DAAM_V3.adminStoragePath)!
        self.newMinter = newMinter
    }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
