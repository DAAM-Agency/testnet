// remove_admin.cdc
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(exAdmin: Address)
{
    let admin   : &DAAM_Mainnet.Admin
    let exAdmin : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath) ?? panic(exAdmin.toString().concat(" is not an Admin."))
	    self.exAdmin = exAdmin
    }

    // Verify exAdmin is an Admin
    pre { DAAM_Mainnet.isAdmin(exAdmin) != nil : exAdmin.toString().concat(" is not an Admin.") }

    execute {
        self.admin.removeAdmin(admin: self.exAdmin)
        log("Remove Admin Requested")
    }
}
