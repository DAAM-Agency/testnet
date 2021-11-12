// is_admin.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

<<<<<<< HEAD
pub fun main(admin: Address): Bool {
=======
pub fun main(admin: Address): Bool? {
>>>>>>> merge_dev
    return DAAM_V5.isAdmin(admin)
}