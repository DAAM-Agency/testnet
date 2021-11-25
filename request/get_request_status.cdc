// get_request_status.cdc
// Returns the Request status using the MID

import DAAM_V6 from 0xa4ad5ea5c0bd2fba
pub fun main(mid: UInt64):Bool {
    return DAAM_V6.getRequestValidity(mid: mid)
}
