// invite_admin.cdc

import DAAM from 0xf8d6e0586b0a20c7

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
