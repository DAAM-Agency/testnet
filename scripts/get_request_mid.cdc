// test.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

pub fun main(): [UInt64] {
    return DAAM_V1.getRequestMIDs()
}
