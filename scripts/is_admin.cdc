// is_admin.cdc

import DAAM_V2.V2 from 0xa4ad5ea5c0bd2fba

pub fun main(admin: Address): Bool {
    return DAAM_V2.isAdmin(admin)
}