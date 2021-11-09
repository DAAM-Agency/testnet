// invite_admin.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &DAAM_V5.Admin
    let newAdmin : Address 

    prepare(acct: AuthAccount) {
        self.admin    = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    execute {
        self.admin.inviteAdmin(newAdmin: self.newAdmin)
        log("Admin Invited")
    }
}
