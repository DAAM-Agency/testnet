// change_creator_status.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, status: Bool) {
    let admin  : &{DAAM_V2.Founder}
    let creator: Address
    let status : Bool

    prepare(acct: AuthAccount) {
        self.creator = creator
        self.status  = status
        self.admin = acct.borrow<&{DAAM_V2.Founder}>(from: DAAM_V2.adminStoragePath)!
    }

    execute {
        self.admin.changeCreatorStatus(creator: self.creator, status: self.status)
        log("Change Creator Status")   
    }
}
