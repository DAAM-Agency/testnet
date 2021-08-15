// invite_admin.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &{DAAM.Founder}
    let newAdmin : Address 

    prepare(acct: AuthAccount) {
        self.admin    = acct.borrow<&{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    execute {
        self.admin.inviteAdmin(newAdmin: self.newAdmin)
        log("Admin Invited")
    }
}
