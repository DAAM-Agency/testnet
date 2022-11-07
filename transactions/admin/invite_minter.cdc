// invite_minter.cdc
// Used for Admin to give Minter access.

import DAAM_Mainnet from 0xfd43f9148d4b725d

transaction(newMinter: Address) {
    let admin     : &DAAMDAAM_Mainnet_Mainnet.Admin
    let newMinter : Address

    prepare(admin: AuthAccount) {
        self.admin     = admin.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
        self.newMinter = newMinter
    }

    pre { DAAM_Mainnet.isMinter(newMinter) == nil : newMinter.toString().concat(" is already a Minter.") }

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
