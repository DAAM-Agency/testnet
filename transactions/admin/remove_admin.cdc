// remove_admin.cdc
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(exAdmin: Address)
{
    let admin   : &DAAM_V23.Admin
    let exAdmin : Address

    prepare(admin: AuthAccount) {
<<<<<<< HEAD
        self.admin = admin.borrow<&DAAM_V23.Admin>(from: DAAM_V23.adminStoragePath) ?? panic(exAdmin.toString().concat(" is not an Admin."))
=======
        self.admin = admin.borrow<&DAAM.Admin>(from: DAAM_V23.adminStoragePath) ?? panic(exAdmin.toString().concat(" is not an Admin."))
>>>>>>> tomerge
	    self.exAdmin = exAdmin
    }

    // Verify exAdmin is an Admin
    pre { DAAM_V23.isAdmin(exAdmin) != nil : exAdmin.toString().concat(" is not an Admin.") }

    execute {
        self.admin.removeAdmin(admin: self.exAdmin)
        log("Remove Admin Requested")
    }
}
