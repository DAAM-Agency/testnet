// refresh_creator_metadatas.cdc
// Used for Admin / Agent to refresh all Metadatas from a Creator.

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address)
{
    let admin   : &DAAM.Admin{DAAM.Agent}
    let creator : Address

    prepare(agent: AuthAccount) {
        self.admin   = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)!
        self.creator = creator
    }

    execute {
        let mlist = self.admin.refreshCreatorMetadatas(creator: self.creator)
        log(mlist)
    }
}
