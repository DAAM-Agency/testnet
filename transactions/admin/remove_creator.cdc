// remove_creator.cdc
// Used for Admin / Agents to remove Creator

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address)
{
    let admin   : &{DAAM.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)!
        self.creator = creator
    }

    pre { DAAM.isAdmin(agent.address) || DAAM.isAgent(agent.address) } // Verify Access
    
    execute {
        self.admin.removeCreator(creator: self.creator)
        log("Remove Creator")
    }
}
