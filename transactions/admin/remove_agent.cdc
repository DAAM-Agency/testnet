// remove_agent_minter.cdc
// Admin can remove an Agent.
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V8.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V8.Admin>(from: DAAM_V8.adminStoragePath)!
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
    pre { DAAM_V8.isAgent(exAgent) != nil : exAgent.toString().concat(" is not an Agent.") }
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Removed Agent")

        if DAAM_V8.isMinter(minter: self.exAgenct) {
            self.admin.removeMinter(minter: self.exAgenct)
            log("Removed Minter")
        }
    }

    // Verify is not an Agent
    post { DAAM_V8.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }

}
