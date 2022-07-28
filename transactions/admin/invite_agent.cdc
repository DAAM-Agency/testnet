// invite_agent.cdc
// Used for Admin to invite another Agent.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V19 from 0xa4ad5ea5c0bd2fba

transaction(newAgent: Address)
{
    let admin    : &DAAM_V19.Admin
    let newAgent : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V19.Admin>(from: DAAM_V19.adminStoragePath)!
        self.newAgent = newAgent
    }
    
    pre {
        DAAM_V19.isAdmin(newAgent)   == nil : newAgent.toString().concat(" is already an Admin.")
        DAAM_V19.isAgent(newAgent)   == nil : newAgent.toString().concat(" is already an Agent.")
        DAAM_V19.isCreator(newAgent) == nil : newAgent.toString().concat(" is already an Creator.")
    }

    execute {
        self.admin.inviteAgent(self.newAgent)
        log("Admin Invited")
    }

    post { DAAM_V19.isAgent(self.newAgent) != nil : self.newAgent.toString().concat(" invitation has not been sent.") }
}
