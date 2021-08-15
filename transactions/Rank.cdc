// invite_minter.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(newMinter: Address) {
    let admin     : &{DAAM.Founder}
    let creator   : &DAAM.Creator

    prepare(acct: AuthAccount) {
        self.admin     = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)
        self.creator     = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
    }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
