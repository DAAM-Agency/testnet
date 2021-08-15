// invite_minter.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V2.Admin{DAAM_V2.Founder}
    let newMinter : Address

    prepare(acct: AuthAccount) {
        self.admin     = acct.borrow<&DAAM_V2.Admin{DAAM_V2.Founder}>(from: DAAM_V2.adminStoragePath)!
        self.newMinter = newMinter
    }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
