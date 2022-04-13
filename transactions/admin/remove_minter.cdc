// remove_admin.cdc
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction(exMinter: Address)
{
    let admin    : &DAAM_V7.Admin
    let exMinter : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V7.Admin>(from: DAAM_V7.adminStoragePath)!
	    self.exMinter = exMinter
    }

    // Verify exMinter is an Admin
    pre { DAAM_V7.isAdmin(admin.address) == true : admin.address.toString().concat(" is not an Admin.") }

    execute {
        self.admin.removeMinter(minter: self.exMinter)
        log("Removed Admin")
    }
}
