// invite_creator.cdc
// Used for Admin / Agent to invite a Creator.
// The invitee Must have a Profile before receiving or accepting this Invitation

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V14

transaction(creator: Address, agentCut: UFix64?)
{
<<<<<<< HEAD
    let admin   : &DAAM_V10.Admin{DAAM_V10.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V10.Admin{DAAM_V10.Agent}>(from: DAAM_V10.adminStoragePath)!
=======
    let admin   : &{DAAM_V14.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM_V14.Admin{DAAM_V14.Agent}>(from: DAAM_V14.adminStoragePath)!
>>>>>>> DAAM_V14
        self.creator = creator
    }

    pre {
<<<<<<< HEAD
        DAAM_V10.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM_V10.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM_V10.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
=======
        DAAM_V14.isAdmin(creator)   == nil : creator.toString().concat(" is already an Admin.")
        DAAM_V14.isAgent(creator)   == nil : creator.toString().concat(" is already an Agent.")
        DAAM_V14.isCreator(creator) == nil : creator.toString().concat(" is already an Creator.")
>>>>>>> DAAM_V14
    }
    
    execute {
        self.admin.inviteCreator(self.creator, agentCut: agentCut)
        log("Creator Invited")
    }

<<<<<<< HEAD
    post { DAAM_V10.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
=======
    post { DAAM_V14.isCreator(self.creator) != nil : self.creator.toString().concat(" invitation has not been sent.") }
>>>>>>> DAAM_V14
}
