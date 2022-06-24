// change_minter_status.cdc
// Used for Admin to change Minter status. True = active, False = frozen

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(minter: Address, status: Bool) {
    let admin   : &DAAM_V14.Admin
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

transaction(minter: Address, status: Bool) {
    let admin   : &DAAM_V15.Admin
>>>>>>> DAAM_V15
    let minter : Address
    let status  : Bool

    prepare(agent: AuthAccount) {
        self.minter = minter  
        self.status  = status
<<<<<<< HEAD
        self.admin = agent.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath)!
    }

    pre { DAAM_V14.isMinter(minter) != nil : minter.toString().concat(" is not a Minter.") }
=======
        self.admin = agent.borrow<&DAAM_V15.Admin>(from: DAAM_V15.adminStoragePath)!
    }

    pre { DAAM_V15.isMinter(minter) != nil : minter.toString().concat(" is not a Minter.") }
>>>>>>> DAAM_V15

    execute {
        self.admin.changeMinterStatus(minter: self.minter, status: self.status)
        log("Change Minter Status")   
    }
}
