// invite_admin.cdc
// Used for Admin to invite another Admin.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V9 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &DAAM_V9.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V9.Admin>(from: DAAM_V9.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    pre {
        DAAM_V9.isAdmin(newAdmin) == nil   : newAdmin.toString().concat(" is already an Admin.")
        DAAM_V9.isAgent(newAdmin) == nil   : newAdmin.toString().concat(" is already an Agent.")
        DAAM_V9.isCreator(newAdmin) == nil : newAdmin.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteAdmin(newAdmin: self.newAdmin)
        log("Admin Invited")
    }
}
