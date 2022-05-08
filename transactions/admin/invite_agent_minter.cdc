// invite_admin_minter.cdc
// Used for Admin to invite another Admin.
// Used for Admin to give Minter access.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM from 0xfd43f9148d4b725d

transaction(newAgent: Address, minterAccess: Bool)
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
        DAAM.isCreator(newAgent) == nil : newAgent.toString().concat(" is already a Creator.")
        DAAM.isMinter(newAgent)  == nil : newAgent.toString().concat(" is already a Minter.")
    }
    
    execute {
        self.admin.inviteAgent(self.newAgent)
        log("Agent Invited")

        if(minterAccess) {
            self.admin.inviteMinter(self.newAgent)
            log("Minter Invited")
        }
    }
}
