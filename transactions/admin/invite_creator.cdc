// invite_creator.cdc
// Used for Admin / Agent to invite a Creator.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, agentCut: UFix64)
{
    let admin  : &DAAM.Admin{DAAM.Agent}
    let creator : Address
    let agentCut: UFix64

    prepare(agent: AuthAccount) {
        self.admin    = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM_V23.adminStoragePath)!
        self.creator  = creator
        self.agentCut = agentCut
    }

    pre {
        DAAM_V23.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM_V23.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM_V23.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteCreator(self.creator, agentCut: self.agentCut)
        log("Creator Invited")
    }

    post { DAAM_V23.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
}
