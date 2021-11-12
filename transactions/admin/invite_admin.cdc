// invite_admin.cdc
// Used for Admin to invite another Admin.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &DAAM_V5.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    pre {
        DAAM_V5.isAdmin(newAdmin) == nil   : newAdmin.toString().concat(" is already an Admin.")
        DAAM_V5.isAgent(newAdmin) == nil   : newAdmin.toString().concat(" is already an Agent.")
        DAAM_V5.isCreator(newAdmin) == nil : newAdmin.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteAdmin(newAdmin: self.newAdmin)
        log("Admin Invited")
    }
}
