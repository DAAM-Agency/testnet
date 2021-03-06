// change_minter_status.cdc
// Used for Admin to change Minter status. True = active, False = frozen

import DAAM_V21 from 0xa4ad5ea5c0bd2fba

transaction(minter: Address, status: Bool) {
    let admin   : &DAAM_V21.Admin
    let minter : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.minter = minter  
        self.status  = status
        self.admin = agent.borrow<&DAAM_V21.Admin>(from: DAAM_V21.adminStoragePath)!
    }

    pre { DAAM_V21.isMinter(minter) != nil : minter.toString().concat(" is not a Minter.") }

    execute {
        self.admin.changeMinterStatus(minter: self.minter, status: self.status)
        log("Change Minter Status")   
    }
}
