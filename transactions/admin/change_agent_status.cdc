// change_agent_status.cdc
// Used for Admin to change Agent status. True = active, False = frozen

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(agent: Address, status: Bool) {
    let admin   : &DAAM_V14.Admin
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction(agent: Address, status: Bool) {
    let admin   : &DAAM_V15.Admin
>>>>>>> DAAM_V15
    let agent : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.agent = agent  
        self.status  = status
<<<<<<< HEAD
        self.admin = agent.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath)!
    }

    pre { DAAM_V14.isAgent(agent) != nil : agent.toString().concat(" is not a Agent.") }
=======
        self.admin = agent.borrow<&DAAM_V15.Admin>(from: DAAM_V15.adminStoragePath)!
    }

    pre { DAAM_V15.isAgent(agent) != nil : agent.toString().concat(" is not a Agent.") }
>>>>>>> DAAM_V15

    execute {
        self.admin.changeAgentStatus(agent: self.agent, status: self.status)
        log("Change Agent Status")   
    }
}
