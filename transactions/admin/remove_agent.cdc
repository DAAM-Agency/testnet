// remove_agent_minter.cdc
// Admin can remove an Agent.
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V7.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V7.Admin>(from: DAAM_V7.adminStoragePath)!
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
    pre {
        DAAM_V7.isAgent(exAgent) != nil : exAgent.toString().concat(" is not an Agent.") 
        DAAM_V7.isAdmin(admin.address) == true : admin.address.toString().concat(" is not an Admin.")
    }
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Removed Agent")

        if DAAM_V7.isMinter(minter: self.exAgenct) {
            self.admin.removeMinter(minter: self.exAgenct)
            log("Removed Minter")
        }
    }

    // Verify is not an Agent
    post { DAAM_V7.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }

}
