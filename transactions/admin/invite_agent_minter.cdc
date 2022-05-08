// invite_admin_minter.cdc
// Used for Admin to invite another Admin.
// Used for Admin to give Minter access.
// The invitee Must have a Profile before receiving or accepting this Invitation

import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction(newAgent: Address, minterAccess: Bool)
{
    let admin    : &DAAM_V10.Admin
    let newAgent : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_V10.Admin>(from: DAAM_V10.adminStoragePath)!
        self.newAgent = newAgent
    }

    pre {
        DAAM_V10.isAdmin(newAgent) == nil   : newAgent.toString().concat(" is already an Admin.")
        DAAM_V10.isAgent(newAgent) == nil   : newAgent.toString().concat(" is already an Agent.")
        DAAM_V10.isCreator(newAgent) == nil : newAgent.toString().concat(" is already an Creator.")
        DAAM_V10.isMinter(newAgent) == nil : newAgent.toString().concat(" is already a Minter.")
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
