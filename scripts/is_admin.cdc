// is_admin.cdc

import DAAM_V11 from 0xfd43f9148d4b725d

pub fun main(admin: Address): Bool? {
    return DAAM_V11.isAdmin(admin)
}
// nil = not an admin, false = invited to be an admin, true = is an admin