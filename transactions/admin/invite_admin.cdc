// invite_admin.cdc
// Used for Admin to invite another Admin.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &DAAM_V6.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V6.Admin>(from: DAAM_V6.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    pre {
        DAAM_V6.isAdmin(newAdmin) == nil   : newAdmin.toString().concat(" is already an Admin.")
        DAAM_V6.isAgent(newAdmin) == nil   : newAdmin.toString().concat(" is already an Agent.")
        DAAM_V6.isCreator(newAdmin) == nil : newAdmin.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteAdmin(newAdmin: self.newAdmin)
        log("Admin Invited")
    }
}
