// invite_creator.cdc
// Used for Admin / Agent to invite a Creator.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address, agentCut: UFix64)
{
    let admin   : &{DAAM.Agent}
    let creator : Address
    let agentCut: UFix64?

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)!
        self.creator = creator
        self.agentCut = agentCut
    }

    pre {
        DAAM.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteCreator(self.creator, agentCut: self.agentCut)
        log("Creator Invited")
    }

    post { DAAM.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
}
