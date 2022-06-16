// invite_admin.cdc
// Used for Admin to invite another Admin.
// The invitee Must have a Profile before receiving or accepting this Invitation

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &DAAM_V10.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V10.Admin>(from: DAAM_V10.adminStoragePath)!
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    let admin    : &DAAM_V14.Admin
    let newAdmin : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath)!
>>>>>>> DAAM_V14
        self.newAdmin = newAdmin
    }

    pre {
<<<<<<< HEAD
        DAAM_V10.isAdmin(newAdmin) == nil   : newAdmin.toString().concat(" is already an Admin.")
        DAAM_V10.isAgent(newAdmin) == nil   : newAdmin.toString().concat(" is already an Agent.")
        DAAM_V10.isCreator(newAdmin) == nil : newAdmin.toString().concat(" is already an Creator.")
=======
        DAAM_V14.isAdmin(newAdmin) == nil   : newAdmin.toString().concat(" is already an Admin.")
        DAAM_V14.isAgent(newAdmin) == nil   : newAdmin.toString().concat(" is already an Agent.")
        DAAM_V14.isCreator(newAdmin) == nil : newAdmin.toString().concat(" is already an Creator.")
>>>>>>> DAAM_V14
    }
    
    execute {
        self.admin.inviteAdmin(self.newAdmin)
        log("Admin Invited")
    }
}
