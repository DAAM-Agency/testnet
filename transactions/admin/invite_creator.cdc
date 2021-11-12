// invite_creator.cdc
// Used for Admin / Agent to invite a Creator.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
<<<<<<< HEAD
    let admin   : &DAAM_V5.Admin
    let creator : Address

    prepare(acct: AuthAccount) {
        self.admin   = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
=======
    let admin   : &{DAAM_V5.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&{DAAM_V5.Agent}>(from: DAAM_V5.adminStoragePath)!
>>>>>>> merge_dev
        self.creator = creator
    }

    pre {
        DAAM_V5.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM_V5.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM_V5.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteCreator(self.creator)
        log("Creator Invited")
    }

    post { DAAM_V5.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
}
