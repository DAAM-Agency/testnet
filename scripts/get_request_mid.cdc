// test.cdc

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

pub fun main(): [UInt64] {
    return DAAM_V7.getRequestMIDs()
}
