// invite_creator.cdc
// Used for Admin / Agent to invite a Creator.
// The invitee Must have a DAAM_Mainnet_Profile before receiving or accepting this Invitation

import DAAM_Mainnet from 0xfd43f9148d4b725d

transaction(creator: Address, agentCut: UFix64)
{
    let admin   : &{DAAM_Mainnet.Agent}
    let creator : Address
    let agentCut: UFix64?

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)!
        self.creator = creator
        self.agentCut = agentCut
    }

    pre {
        DAAM_Mainnet.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM_Mainnet.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM_Mainnet.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
    }
    
    execute {
        self.admin.inviteCreator(self.creator, agentCut: self.agentCut)
        log("Creator Invited")
    }

    post { DAAM_Mainnet.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
}
