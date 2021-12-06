// get_metadata_status.cdc
// Used to get Metadata status. Which are approved or disapproved.

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

pub fun main(): {UInt64:Bool} {
    return DAAM_V7.getMetadataStatus()
}
