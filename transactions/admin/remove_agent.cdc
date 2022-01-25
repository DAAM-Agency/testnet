// remove_agent.cdc
// Admin can remove an Agent.

import DAAM from 0xfd43f9148d4b725d

transaction(exAgent: Address) {
    let admin   : &DAAM.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
    pre { DAAM.isAgent(exAgent) == true : exAgent.toString().concat(" is not an Agent.") }
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Agent Removed.")
    }

    // Verify is not an Agent
    post { DAAM.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }

}
