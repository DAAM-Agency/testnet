// remove_agent.cdc
// Admin can remove an Agent.

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V6.Agent
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V6.Admin>(from: DAAM_V6.adminStoragePath)!
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
    pre { DAAM_V6.isAgent(exAgent) == true : exAgent.toString().concat(" is not an Agent.") }
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Remove Agent Requested")
    }

    // Verify is not an Agent
    post { DAAM_V6.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }

}
