// invite_creator.cdc
// Used for Admin / Agent to invite a Creator.
// The invitee Must have a Profile before receiving or accepting this Invitation

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, agentCut: UFix64)
{
    let admin   : &{DAAM_V14.Agent}
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, agentCut: UFix64)
{
    let admin   : &{DAAM_V15.Agent}
>>>>>>> DAAM_V15
    let creator : Address
    let agentCut: UFix64?

    prepare(agent: AuthAccount) {
<<<<<<< HEAD
        self.admin   = agent.borrow<&DAAM_V14.Admin{DAAM_V14.Agent}>(from: DAAM_V14.adminStoragePath)!
=======
        self.admin   = agent.borrow<&DAAM_V15.Admin{DAAM_V15.Agent}>(from: DAAM_V15.adminStoragePath)!
>>>>>>> DAAM_V15
        self.creator = creator
        self.agentCut = agentCut
    }

    pre {
<<<<<<< HEAD
        DAAM_V14.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM_V14.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM_V14.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
=======
        DAAM_V15.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM_V15.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM_V15.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
>>>>>>> DAAM_V15
    }
    
    execute {
        self.admin.inviteCreator(self.creator, agentCut: self.agentCut)
        log("Creator Invited")
    }

<<<<<<< HEAD
    post { DAAM_V14.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
=======
    post { DAAM_V15.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
>>>>>>> DAAM_V15
}
