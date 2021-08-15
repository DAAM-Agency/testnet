// is_admin.cdc

import DAAM from 0xf8d6e0586b0a20c7

pub fun main(admin: Address): Bool {
    return DAAM.isAdmin(admin)
}