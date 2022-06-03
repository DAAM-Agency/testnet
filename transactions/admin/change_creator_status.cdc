// change_creator_status.cdc
// Used for Admin / Agents to change Creator status. True = active, False = frozen

import DAAM_V11 from 0xfd43f9148d4b725d

transaction(creator: Address, status: Bool) {
    let admin   : &{DAAM_V11.Agent}
    let creator : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.creator = creator  
        self.status  = status
        self.admin = agent.borrow<&{DAAM_V11.Agent}>(from: DAAM_V11.adminStoragePath)!
    }

    pre { DAAM_V11.isCreator(creator) != nil : creator.toString().concat(" is not a Creator.") }

    execute {
        self.admin.changeCreatorStatus(creator: self.creator, status: self.status)
        log("Change Creator Status")   
    }
}
