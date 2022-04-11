// remove_agent.cdc
// Admin can remove an Agent.

import DAAM_V8.V8.V8_V8.. from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V8.V8..Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V8.V8..Admin>(from: DAAM_V8.V8..adminStoragePath)!
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
    pre { DAAM_V8.V8..isAgent(exAgent) == true : exAgent.toString().concat(" is not an Agent.") }
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Agent Removed.")
    }

    // Verify is not an Agent
    post { DAAM_V8.V8..isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }

}
