// invite_admin.cdc
// Used for Admin to invite another Admin.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V19 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &DAAM_V19.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V19.Admin>(from: DAAM_V19.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    pre {
        DAAM_V19.isAdmin(newAdmin) == nil   : newAdmin.toString().concat(" is already an Admin.")
        DAAM_V19.isAgent(newAdmin) == nil   : newAdmin.toString().concat(" is already an Agent.")
        DAAM_V19.isCreator(newAdmin) == nil : newAdmin.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteAdmin(self.newAdmin)
        log("Admin Invited")
    }
}
