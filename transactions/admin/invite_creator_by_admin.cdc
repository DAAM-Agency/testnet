// invite_creator.cdc
// Used for Admin / Agent to invite a Creator.
// The invitee Must have a DAAM_Profile before receiving or accepting this Invitation

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(creator: Address)
{
    let admin   : &{DAAM_Mainnet.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)!
        self.creator = creator
    }

    pre {
        DAAM_Mainnet.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM_Mainnet.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM_Mainnet.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteCreator(self.creator, agentCut: nil)
        log("Creator Invited")
    }

    post { DAAM_Mainnet.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
}
