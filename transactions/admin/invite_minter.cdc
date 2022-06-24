// invite_minter.cdc
// Used for Admin to give Minter access.

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V14.Admin
    let newMinter : Address

    prepare(admin: AuthAccount) {
        self.admin     = admin.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath)!
        self.newMinter = newMinter
    }

    pre { DAAM_V14.isMinter(newMinter) == nil : newMinter.toString().concat(" is already a Minter.") }
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction(newMinter: Address) {
    let admin     : &DAAM_V15.Admin
    let newMinter : Address

    prepare(admin: AuthAccount) {
        self.admin     = admin.borrow<&DAAM_V15.Admin>(from: DAAM_V15.adminStoragePath)!
        self.newMinter = newMinter
    }

    pre { DAAM_V15.isMinter(newMinter) == nil : newMinter.toString().concat(" is already a Minter.") }
>>>>>>> DAAM_V15

    execute {
        self.admin.inviteMinter(self.newMinter)
        log("Minter Invited")
    }
}
