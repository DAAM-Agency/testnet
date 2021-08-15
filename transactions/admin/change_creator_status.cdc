// change_creator_status.cdc

import DAAM from 0xf8d6e0586b0a20c7

transaction(creator: Address, status: Bool) {
    let admin  : &{DAAM.Founder}
    let creator: Address
    let status : Bool

    prepare(acct: AuthAccount) {
        self.creator = creator
        self.status  = status
        self.admin = acct.borrow<&{DAAM.Founder}>(from: DAAM.adminStoragePath)!
    }

    execute {
        self.admin.changeCreatorStatus(creator: self.creator, status: self.status)
        log("Change Creator Status")   
    }
}
