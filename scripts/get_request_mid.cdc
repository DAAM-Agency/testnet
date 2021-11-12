// test.cdc

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

pub fun main(): [UInt64] {
    return DAAM_V6.getRequestMIDs()
}
