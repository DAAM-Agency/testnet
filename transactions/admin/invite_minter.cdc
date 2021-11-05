// invite_minter.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(newMinter: Address) {
    let admin     : &DAAM.Admin
    let newMinter : Address

    prepare(acct: AuthAccount) {
        self.admin     = acct.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
        self.newMinter = newMinter
    }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
