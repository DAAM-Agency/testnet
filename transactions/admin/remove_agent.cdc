// remove_agent_minter.cdc
// Admin can remove an Agent.
// Two Admins can remove another Admin. Must be run by two Admins.

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V10.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V10.Admin>(from: DAAM_V10.adminStoragePath)!
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(exAgent: Address) {
    let admin   : &DAAM_V14.Admin
    let exAgent : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath) ?? panic(exAgent.toString().concat(" is not an Agent."))
>>>>>>> DAAM_V14
	    self.exAgent = exAgent
    }

    // Verify exAgent is an Agent
<<<<<<< HEAD
    pre { DAAM_V10.isAgent(exAgent) != nil : exAgent.toString().concat(" is not an Agent.") }
=======
    pre { DAAM_V14.isAgent(exAgent) != nil : exAgent.toString().concat(" is not an Agent.") }
>>>>>>> DAAM_V14
    
    execute {
        self.admin.removeAgent(agent: self.exAgent)
        log("Removed Agent")

<<<<<<< HEAD
        if DAAM_V10.isMinter(self.exAgent) != nil {
=======
        if DAAM_V14.isMinter(self.exAgent) != nil {
>>>>>>> DAAM_V14
            self.admin.removeMinter(minter: self.exAgent)
            log("Removed Minter")
        }
    }

    // Verify is not an Agent
<<<<<<< HEAD
    post { DAAM_V10.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }

=======
    post { DAAM_V14.isAgent(self.exAgent) == nil : self.exAgent.toString().concat(" is still an Agent.") }
>>>>>>> DAAM_V14
}
