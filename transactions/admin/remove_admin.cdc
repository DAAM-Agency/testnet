// remove_admin.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(exAdmin: Address)
{
    let admin   : &{DAAM_V1.Founder}
    let exAdmin : Address

    prepare(acct: AuthAccount) {
        self.admin = acct.borrow<&DAAM_V1.Admin{DAAM_V1.Founder}>(from: DAAM_V1.adminStoragePath)!
	self.exAdmin = exAdmin
    }

    execute {
        self.admin.removeAdmin(admin: self.exAdmin)
        log("Remove Admin Requested")
    }
}
