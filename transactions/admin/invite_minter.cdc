// invite_minter.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(newMinter: Address) {
    let admin     : &DAAM.Admin
    let newMinter : Address

    prepare(admin: AuthAccount) {
        self.admin     = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
        self.newMinter = newMinter
    }

    pre { DAAM.isAdmin(agent.address) } // Verify Access

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
