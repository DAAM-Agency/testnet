// remove_admin.cdc
// Two Admins can remove another Admin. Must be run by two Admins.

import DAAM from 0xfd43f9148d4b725d

transaction(exMinter: Address)
{
    let admin    : &DAAM.Admin
    let exMinter : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
	    self.exMinter = exMinter
    }

    // Verify exMinter is an Admin
    pre { DAAM.isMinter(exMinter) != nil : admin.address.toString().concat(" does not have Minter Key.") }

    execute {
        self.admin.removeMinter(minter: self.exMinter)
        log("Removed Minter")
    }
}
