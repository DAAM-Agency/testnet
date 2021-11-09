// remove_agent.cdc
// Admin can remove an Agent.

import DAAM from 0xfd43f9148d4b725d

transaction(exAgent: Address)
{
    let admin   : &DAAM.Agent
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
	    self.exAgent = exAgent
    }

    pre { DAAM.isAgent(exAgent) } // Verify exAgent is an Agent

    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Remove Agent Requested")
    }

    post { !DAAM.isAgent(self.exAgent) } // Verify is not an Agent
}
