// invite_admin.cdc
// Used for Admin to invite another Admin.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM from 0xfd43f9148d4b725d

transaction(newAdmin: Address)
{
    let admin    : &DAAM.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
        self.newAdmin = newAdmin
    }

    pre {
        DAAM.isAdmin(newAdmin) == nil   : newAdmin.toString().concat(" is already an Admin.")
        DAAM.isAgent(newAdmin) == nil   : newAdmin.toString().concat(" is already an Agent.")
        DAAM.isCreator(newAdmin) == nil : newAdmin.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteAdmin(self.newAdmin)
        log("Admin Invited")
    }
}
