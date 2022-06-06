// change_minter_status.cdc
// Used for Admin to change Minter status. True = active, False = frozen

import DAAM from 0xfd43f9148d4b725d

transaction(minter: Address, status: Bool) {
    let admin   : &DAAM.Admin
    let minter : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.minter = minter  
        self.status  = status
        self.admin = agent.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
    }

    pre { DAAM.isMinter(minter) != nil : minter.toString().concat(" is not a Minter.") }

    execute {
        self.admin.changeMinterStatus(minter: self.minter, status: self.status)
        log("Change Minter Status")   
    }
}
