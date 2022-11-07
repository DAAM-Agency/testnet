// is_admin.cdc

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(admin: Address): Bool? {
    return DAAM_Mainnet.isAdmin(admin)
}
// nil = not an admin, false = invited to be an admin, true = is an admin