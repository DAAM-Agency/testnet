// invite_admin_minter.cdc
// Used for Admin to invite another Admin.
// Used for Admin to give Minter access.
// The invitee Must have a DAAM_Mainnet_Profile before receiving or accepting this Invitation

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction(newAgent: Address, minterAccess: Bool)
{
    let admin    : &DAAM_Mainnet.Admin
    let newAgent : Address 

    prepare(admin: AuthAccount) {
        self.admin    = admin.borrow<&DAAM_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
        self.newAgent = newAgent
    }

    pre {
        DAAM_Mainnet.isAdmin(newAgent)   == nil : newAgent.toString().concat(" is already an Admin.")
        DAAM_Mainnet.isAgent(newAgent)   == nil : newAgent.toString().concat(" is already an Agent.")
        DAAM_Mainnet.isCreator(newAgent) == nil : newAgent.toString().concat(" is already a Creator.")
        DAAM_Mainnet.isMinter(newAgent)  == nil : newAgent.toString().concat(" is already a Minter.")
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
