// remove_admin.cdc
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(exAdmin: Address)
{
    let admin   : &DAAM_V5.Admin
    let exAdmin : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
	    self.exAdmin = exAdmin
    }

    // Verify exAdmin is an Admin
    pre { DAAM_V5.isAdmin(exAdmin) == true : exAdmin.toString().concat(" is not an Admin.") }

    execute {
        self.admin.removeAdmin(admin: self.exAdmin)
        log("Remove Admin Requested")
    }
}
