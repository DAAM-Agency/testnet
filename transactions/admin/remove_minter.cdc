// remove_admin.cdc
// Two Admins can remove another Admin. Must be run by two Admins.

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

transaction(exMinter: Address)
{
    let admin    : &DAAM_V10.Admin
    let exMinter : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V10.Admin>(from: DAAM_V10.adminStoragePath)!
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction(exMinter: Address)
{
    let admin    : &DAAM_V14.Admin
    let exMinter : Address

    prepare(admin: AuthAccount) {
        self.admin = admin.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath) ?? panic(exMinter.toString().concat(" is not a Minter."))
>>>>>>> DAAM_V14
	    self.exMinter = exMinter
    }

    // Verify exMinter is an Admin
<<<<<<< HEAD
    pre { DAAM_V10.isMinter(exMinter) != nil : admin.address.toString().concat(" does not have Minter Key.") }
=======
    pre { DAAM_V14.isMinter(exMinter) != nil : admin.address.toString().concat(" does not have Minter Key.") }
>>>>>>> DAAM_V14

    execute {
        self.admin.removeMinter(minter: self.exMinter)
        log("Removed Minter")
    }
}
