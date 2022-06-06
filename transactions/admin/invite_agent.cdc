// invite_agent.cdc
// Used for Admin to invite another Agent.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM from 0xfd43f9148d4b725d

transaction(newAgent: Address)
{
    let admin    : &DAAM.Admin
    let newAgent : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
        self.newAgent = newAgent
    }
    
    pre {
        DAAM.isAdmin(newAgent)   == nil : newAgent.toString().concat(" is already an Admin.")
        DAAM.isAgent(newAgent)   == nil : newAgent.toString().concat(" is already an Agent.")
        DAAM.isCreator(newAgent) == nil : newAgent.toString().concat(" is already an Creator.")
    }

    execute {
        self.admin.inviteAgent(self.newAgent)
        log("Admin Invited")
    }

    post { DAAM.isAgent(self.newAgent) != nil : self.newAgent.toString().concat(" invitation has not been sent.") }
}
