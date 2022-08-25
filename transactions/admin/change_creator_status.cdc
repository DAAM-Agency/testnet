// change_creator_status.cdc
// Used for Admin / Agents to change Creator status. True = active, False = frozen

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, status: Bool) {
    let admin   : &{DAAM_V22.Agent}
    let creator : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.creator = creator  
        self.status  = status
        self.admin = agent.borrow<&{DAAM_V22.Agent}>(from: DAAM_V22.adminStoragePath)!
    }

    pre { DAAM_V22.isCreator(creator) != nil : creator.toString().concat(" is not a Creator.") }

    execute {
        self.admin.changeCreatorStatus(creator: self.creator, status: self.status)
        log("Change Creator Status")   
    }
}
