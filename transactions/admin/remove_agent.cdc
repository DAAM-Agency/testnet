// remove_agent_minter.cdc
// Admin can remove an Agent.
// Two Admins can remove another Admin. Must be run by two Admins.

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V14.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath) ?? panic(exAgent.toString().concat(" is not an Agent."))
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V15.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V15.Admin>(from: DAAM_V15.adminStoragePath) ?? panic(exAgent.toString().concat(" is not an Agent."))
>>>>>>> DAAM_V15
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
<<<<<<< HEAD
    pre { DAAM_V14.isAgent(exAgent) != nil : exAgent.toString().concat(" is not an Agent.") }
=======
    pre { DAAM_V15.isAgent(exAgent) != nil : exAgent.toString().concat(" is not an Agent.") }
>>>>>>> DAAM_V15
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Removed Agent")

<<<<<<< HEAD
        if DAAM_V14.isMinter(self.exAgent) != nil {
=======
        if DAAM_V15.isMinter(self.exAgent) != nil {
>>>>>>> DAAM_V15
            self.admin.removeMinter(minter: self.exAgent)
            log("Removed Minter")
        }
    }

    // Verify is not an Agent
<<<<<<< HEAD
    post { DAAM_V14.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }
=======
    post { DAAM_V15.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }
>>>>>>> DAAM_V15
}
