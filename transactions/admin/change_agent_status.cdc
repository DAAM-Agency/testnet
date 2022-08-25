// change_agent_status.cdc
// Used for Admin to change Agent status. True = active, False = frozen

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

transaction(agent: Address, status: Bool) {
    let admin   : &DAAM_V22.Admin
    let agent : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.agent = agent  
        self.status  = status
<<<<<<< HEAD
        self.admin = agent.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath)!
=======
        self.admin = agent.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
    }

    pre { DAAM_V22.isAgent(agent) != nil : agent.toString().concat(" is not a Agent.") }

    execute {
        self.admin.changeAgentStatus(agent: self.agent, status: self.status)
        log("Change Agent Status")   
    }
}
