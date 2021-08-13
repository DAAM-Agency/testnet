// change_metadata_status.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, status: Bool)
{
    let admin : &{DAAM.Founder}
    let mid   : UInt64
    let status: Bool

    prepare(acct: AuthAccount) {
        self.admin  = acct.borrow<&{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        self.mid    = mid
        self.status = status
    }

    execute {
        self.admin.changeMetadataStatus(mid: self.mid, status: self.status)
        log("Change Metadata Status")
    }
}
