// view _creator_metadata.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(creator: Address)
{
    let admin   : &{DAAM.Agent}
    let creator : Address

    prepare(admin: AuthAccount) {
        self.admin   = admin.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)!
        self.creator = admin.address
    }

    execute {
        self.admin.viewCreatorMetadata(creator: self.creator)
        log("Change Metadata Status")
    }
}
