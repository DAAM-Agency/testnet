// get_request.cdc
// TODO Consider deleting
import DAAM from 0xfd43f9148d4b725d

pub fun main(): [UInt64] {
    return DAAM.getRequestMIDs()
}
