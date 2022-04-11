// remove_minter.cdc
// Admin can remove an Minter.

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

transaction(exMinter: Address) {
    let admin   : &DAAM_V8.Admin
    let exMinter : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V8.Admin>(from: DAAM_V8.adminStoragePath)!
	    self.exMinter = exMinter
    }

    // Verify exMinter is a Minter
    pre { DAAM_V8.isMinter(exMinter) == true : exMinter.toString().concat(" is not an Minter.") }
    
    execute {
        self.admin.removeMinter(minter: self.exMinter)
        log("Remove Minter.")
    }

    // Verify is not an Minter
    post { DAAM_V8.isMinter(self.exMinter) == nil : self.exMinter.toString().concat(" is still an Minter.") }

}
