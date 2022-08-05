// invite_creator.cdc
// Used for Admin / Agent to invite a Creator.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V21.V21 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
    let admin   : &{DAAM_V21.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V21.Admin{DAAM_V21.Agent}>(from: DAAM_V21.V21.adminStoragePath)!
        self.creator = creator
    }

    pre {
        DAAM_V21.V21.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM_V21.V21.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM_V21.V21.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteCreator(self.creator, agentCut: nil)
        log("Creator Invited")
    }

    post { DAAM_V21.V21.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
}
