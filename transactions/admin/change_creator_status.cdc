// change_creator_status.cdc
// Used for Admin / Agents to change Creator status. True = active, False = frozen

import DAAM from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, status: Bool) {
    let admin  : &DAAM.Admin{DAAM.Agent}
    let creator : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.creator = creator  
        self.status  = status
        self.admin = agent.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)!
    }

    pre { DAAM.isCreator(creator) != nil : creator.toString().concat(" is not a Creator.") }

    execute {
        self.admin.changeCreatorStatus(creator: self.creator, status: self.status)
        log("Change Creator Status")   
    }
}
