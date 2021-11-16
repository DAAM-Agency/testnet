// get_metadata_status.cdc
// Used to get Metadata status. Which are approved or disapproved.


// TODO Consider deleting
import DAAM from 0xfd43f9148d4b725d

pub fun main(): {UInt64:Bool} {
    return DAAM.getMetadataStatus()
}
