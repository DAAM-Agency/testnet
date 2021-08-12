// remove_admin.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(exAdmin: Address)
{
    let admin   : &{DAAM.Founder}
    let exAdmin : Address

    prepare(acct: AuthAccount) {
        self.admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
    }

    execute {
        self.admin.removeAdmin(admin: self.exAdmin)
        log("Remove Admin Requested")
    }
}
