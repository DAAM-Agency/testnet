// remove_admin.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

transaction(exAdmin: Address)
{
    let admin   : &{DAAM_V2.Founder}
    let exAdmin : Address

    prepare(acct: AuthAccount) {
        self.admin = acct.borrow<&DAAM_V2.Admin{DAAM_V2.Founder}>(from: DAAM_V2.adminStoragePath)!
	self.exAdmin = exAdmin
    }

    execute {
        self.admin.removeAdmin(admin: self.exAdmin)
        log("Remove Admin Requested")
    }
}
