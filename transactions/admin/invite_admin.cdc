// invite_admin.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &{DAAM_V3.Founder}
    let newAdmin : Address 

    prepare(acct: AuthAccount) {
        self.admin    = acct.borrow<&{DAAM_V3.Founder}>(from: DAAM_V3.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    execute {
        self.admin.inviteAdmin(newAdmin: self.newAdmin)
        log("Admin Invited")
    }
}
