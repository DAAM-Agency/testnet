// remove_agent_minter.cdc
// Admin can remove an Agent.
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
    pre {
        DAAM.isAgent(exAgent) != nil : exAgent.toString().concat(" is not an Agent.") 
        DAAM.isAdmin(admin.address) == true : admin.address.toString().concat(" is not an Admin.")
    }
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Removed Agent")

        if DAAM.isMinter(minter: self.exAgenct) {
            self.admin.removeMinter(minter: self.exAgenct)
            log("Removed Minter")
        }
    }

    // Verify is not an Agent
    post { DAAM.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }

}
