// change_creator_status.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address, status: Bool) {
    let admin   : &{DAAM.Agent}
    let creator : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.creator = creator
        self.status  = status
        self.admin = agent.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)!
    }

    pre { DAAM.isAdmin(agent.address) || DAAM.isAgent(agent.address) } // Verify Access

    execute {
        self.admin.changeCreatorStatus(creator: self.creator, status: self.status)
        log("Change Creator Status")   
    }
}
