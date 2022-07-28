// remove_admin.cdc
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM_V20 from 0xa4ad5ea5c0bd2fba

transaction(exMinter: Address)
{
    let admin    : &DAAM_V20.Admin
    let exMinter : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V20.Admin>(from: DAAM_V20.adminStoragePath) ?? panic(exMinter.toString().concat(" is not a Minter."))
	    self.exMinter = exMinter
    }

    // Verify exMinter is an Admin
    pre { DAAM_V20.isMinter(exMinter) != nil : admin.address.toString().concat(" does not have Minter Key.") }

    execute {
        self.admin.removeMinter(minter: self.exMinter)
        log("Removed Minter")
    }
}
