// remove_agent_minter.cdc
// Admin can remove an Agent.
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM_V12 from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V12.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V12.Admin>(from: DAAM_V12.adminStoragePath) ?? panic(exAgent.toString().concat(" is not an Agent."))
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
    pre { DAAM_V12.isAgent(exAgent) != nil : exAgent.toString().concat(" is not an Agent.") }
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Removed Agent")

        if DAAM_V12.isMinter(self.exAgent) != nil {
            self.admin.removeMinter(minter: self.exAgent)
            log("Removed Minter")
        }
    }

    // Verify is not an Agent
    post { DAAM_V12.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }
}
