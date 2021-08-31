// remove_admin.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(exAdmin: Address)
{
    let admin   : &{DAAM.Founder}
    let exAdmin : Address

    prepare(acct: AuthAccount) {
        self.admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
	    self.exAdmin = exAdmin
    }

    execute {
        self.admin.removeAdmin(admin: self.exAdmin)
        log("Remove Admin Requested")
    }
}
