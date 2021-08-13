// invite_minter.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(newMinter: Address) {
    let admin     : &DAAM.Admin{DAAM.Founder}
    let newMinter : Address

    prepare(acct: AuthAccount) {
        self.admin     = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        self.newMinter = newMinter
    }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
