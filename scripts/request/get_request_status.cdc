// get_request_status.cdc
// Returns the Request status using the MID

import DAAM_V7 from 0xa4ad5ea5c0bd2fba
pub fun main(creator: Address, mid: UInt64):Bool? {
    return DAAM_V7.getRequestValidity(creator: creator, mid: mid)
}
   