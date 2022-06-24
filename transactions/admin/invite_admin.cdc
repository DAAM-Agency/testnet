// invite_admin.cdc
// Used for Admin to invite another Admin.
// The invitee Must have a Profile before receiving or accepting this Invitation

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &DAAM_V14.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath)!
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &DAAM_V15.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V15.Admin>(from: DAAM_V15.adminStoragePath)!
>>>>>>> DAAM_V15
        self.newAdmin = newAdmin
    }

    pre {
<<<<<<< HEAD
        DAAM_V14.isAdmin(newAdmin) == nil   : newAdmin.toString().concat(" is already an Admin.")
        DAAM_V14.isAgent(newAdmin) == nil   : newAdmin.toString().concat(" is already an Agent.")
        DAAM_V14.isCreator(newAdmin) == nil : newAdmin.toString().concat(" is already an Creator.")
=======
        DAAM_V15.isAdmin(newAdmin) == nil   : newAdmin.toString().concat(" is already an Admin.")
        DAAM_V15.isAgent(newAdmin) == nil   : newAdmin.toString().concat(" is already an Agent.")
        DAAM_V15.isCreator(newAdmin) == nil : newAdmin.toString().concat(" is already an Creator.")
>>>>>>> DAAM_V15
    }
    
    execute {
        self.admin.inviteAdmin(self.newAdmin)
        log("Admin Invited")
    }
}
