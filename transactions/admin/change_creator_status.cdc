// change_creator_status.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(creator: Address, status: Bool) {
<<<<<<< HEAD
    let admin  : &DAAM_V5.Admin
=======
    let admin  : &DAAM.Admin
>>>>>>> dev-emulator
    let creator: Address
    let status : Bool

    prepare(acct: AuthAccount) {
        self.creator = creator
        self.status  = status
<<<<<<< HEAD
        self.admin = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
=======
        self.admin = acct.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
>>>>>>> dev-emulator
    }

    execute {
        self.admin.changeCreatorStatus(creator: self.creator, status: self.status)
        log("Change Creator Status")   
    }
}
