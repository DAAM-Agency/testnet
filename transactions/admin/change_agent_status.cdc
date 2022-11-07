// change_agent_status.cdc
// Used for Admin to change Agent status. True = active, False = frozen

import DAAM_Mainnet from 0xfd43f9148d4b725d

transaction(agent: Address, status: Bool) {
    let admin   : &DAAMDAAM_Mainnet_Mainnet.Admin
    let agent : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.agent = agent  
        self.status  = status
        self.admin = agent.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
    }

    pre { DAAM_Mainnet.isAgent(agent) != nil : agent.toString().concat(" is not a Agent.") }

    execute {
        self.admin.changeAgentStatus(agent: self.agent, status: self.status)
        log("Change Agent Status")   
    }
}
