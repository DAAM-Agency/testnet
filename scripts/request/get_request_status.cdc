// get_request_status.cdc
// Returns the Request status using the MID

import DAAM from 0xfd43f9148d4b725d
pub fun main(mid: UInt64):Bool {
    return DAAM.getRequestValidity(mid: mid)
}
