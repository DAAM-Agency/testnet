// change_metadata_status.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, status: Bool)
{
    let admin : &DAAM_V5.Admin
    let mid   : UInt64
    let status: Bool

    prepare(acct: AuthAccount) {
        self.admin  = acct.borrow<&DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)!
        self.mid    = mid
        self.status = status
    }

    execute {
        self.admin.changeMetadataStatus(mid: self.mid, status: self.status)
        log("Change Metadata Status")
    }
}
