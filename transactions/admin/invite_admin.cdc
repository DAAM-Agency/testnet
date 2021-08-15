// invite_admin.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &{DAAM_V1.Founder}
    let newAdmin : Address 

    prepare(acct: AuthAccount) {
        self.admin    = acct.borrow<&{DAAM_V1.Founder}>(from: DAAM_V1.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    execute {
        self.admin.inviteAdmin(newAdmin: self.newAdmin)
        log("Admin Invited")
    }
}
