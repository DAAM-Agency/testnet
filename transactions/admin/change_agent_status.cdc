// change_agent_status.cdc
// Used for Admin to change Agent status. True = active, False = frozen

import DAAM from 0xfd43f9148d4b725d

transaction(agent: Address, status: Bool) {
    let admin   : &DAAM.Admin
    let agent : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.agent = agent  
        self.status  = status
        self.admin = agent.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
    }

    pre { DAAM.isAgent(agent) != nil : agent.toString().concat(" is not a Agent.") }

    execute {
        self.admin.changeAgentStatus(agent: self.agent, status: self.status)
        log("Change Agent Status")   
    }
}
