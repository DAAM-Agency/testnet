// is_admin.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(admin: Address): Bool? {
    return DAAM.isAdmin(admin)
}