// change_agent_status.cdc
// Used for Admin to change Agent status. True = active, False = frozen

import DAAM_V8.V8.V8_V8.. from 0xa4ad5ea5c0bd2fba

transaction(agent: Address, status: Bool) {
    let admin   : &DAAM_V8.V8..Admin
    let agent : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.agent = agent  
        self.status  = status
        self.admin = agent.borrow<&DAAM_V8.V8..Admin>(from: DAAM_V8.V8..adminStoragePath)!
    }

    pre { DAAM_V8.V8..isAgent(agent) != nil : agent.toString().concat(" is not a Agent.") }

    execute {
        self.admin.changeAgentStatus(agent: self.agent, status: self.status)
        log("Change Agent Status")   
    }
}
