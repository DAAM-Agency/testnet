// remove_agent.cdc
// Admin can remove an Agent.

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V7.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V7.Admin>(from: DAAM_V7.adminStoragePath)!
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
    pre { DAAM_V7.isAgent(exAgent) == true : exAgent.toString().concat(" is not an Agent.") }
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Remove Agent Requested")
    }

    // Verify is not an Agent
    post { DAAM_V7.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }

}
