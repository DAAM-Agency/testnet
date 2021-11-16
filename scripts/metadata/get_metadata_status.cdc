// get_metadata_status.cdc
// Used to get Metadata status. Which are approved or disapproved.

import DAAM from 0xfd43f9148d4b725d

pub fun main(): {Bool: [UInt64]} {
    var list: {Bool: [UInt64]} = {}
    let metadatas = DAAM.getMetadataStatus()
    var trueStatus : [UInt64] = []
    var falseStatus: [UInt64] = []
    for m in metadatas.keys {
        metadatas[m]! ? trueStatus.append(m) : falseStatus.append(m)        
    }
    list[true]  = trueStatus
    list[false] = falseStatus
    return list
}
