// remove_minter.cdc
// Admin can remove an Minter.

import DAAM from 0xfd43f9148d4b725d

transaction(exMinter: Address) {
    let admin   : &DAAM.Admin
    let exMinter : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
	    self.exMinter = exMinter
    }

    // Verify exMinter is a Minter
    pre { DAAM.isMinter(exMinter) == true : exMinter.toString().concat(" is not an Minter.") }
    
    execute {
        self.admin.removeMinter(minter: self.exMinter)
        log("Remove Minter.")
    }

    // Verify is not an Minter
    post { DAAM.isMinter(self.exMinter) == nil : self.exMinter.toString().concat(" is still an Minter.") }

}
