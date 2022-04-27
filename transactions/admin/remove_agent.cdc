// remove_agent_minter.cdc
// Admin can remove an Agent.
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM from 0xfd43f9148d4b725d

transaction(exAgent: Address) {
    let admin   : &DAAM.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
    pre { DAAM.isAgent(exAgent) != nil : exAgent.toString().concat(" is not an Agent.") }
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Removed Agent")

        if DAAM.isMinter(self.exAgent) != nil {
            self.admin.removeMinter(minter: self.exAgent)
            log("Removed Minter")
        }
    }

    // Verify is not an Agent
    post { DAAM.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }
}
