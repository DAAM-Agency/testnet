// remove_admin.cdc
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

transaction(exAdmin: Address)
{
    let admin   : &DAAM_V22.Admin
    let exAdmin : Address

    prepare(admin: AuthAccount) {
<<<<<<< HEAD
        self.admin = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath) ?? panic(exAdmin.toString().concat(" is not an Admin."))
=======
        self.admin = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath) ?? panic(exAdmin.toString().concat(" is not an Admin."))
>>>>>>> 586a0096 (updated FUSD Address)
	    self.exAdmin = exAdmin
    }

    // Verify exAdmin is an Admin
    pre { DAAM_V22.isAdmin(exAdmin) != nil : exAdmin.toString().concat(" is not an Admin.") }

    execute {
        self.admin.removeAdmin(admin: self.exAdmin)
        log("Remove Admin Requested")
    }
}
