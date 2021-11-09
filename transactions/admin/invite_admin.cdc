// invite_admin.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(newAdmin: Address)
{
    let admin    : &DAAM.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    pre { DAAM.isAdmin(agent.address) } // Verify Access

    execute {
        self.admin.inviteAdmin(newAdmin: self.newAdmin)
        log("Admin Invited")
    }
}
