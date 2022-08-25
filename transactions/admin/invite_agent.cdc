// invite_agent.cdc
// Used for Admin to invite another Agent.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V22.V22 from 0xa4ad5ea5c0bd2fba

transaction(newAgent: Address)
{
    let admin    : &DAAM_V22.Admin
    let newAgent : Address 

    prepare(admin: AuthAccount) {
<<<<<<< HEAD
        self.admin    = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.V22.adminStoragePath)!
=======
        self.admin    = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
        self.newAgent = newAgent
    }
    
    pre {
        DAAM_V22.V22.isAdmin(newAgent)   == nil : newAgent.toString().concat(" is already an Admin.")
        DAAM_V22.V22.isAgent(newAgent)   == nil : newAgent.toString().concat(" is already an Agent.")
        DAAM_V22.V22.isCreator(newAgent) == nil : newAgent.toString().concat(" is already an Creator.")
    }

    execute {
        self.admin.inviteAgent(self.newAgent)
        log("Admin Invited")
    }

    post { DAAM_V22.V22.isAgent(self.newAgent) != nil : self.newAgent.toString().concat(" invitation has not been sent.") }
}
