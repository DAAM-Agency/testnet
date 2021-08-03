// change_metadata_status.cdc

import DAAM from x51e2c02e69b53477

transaction(mid: UInt64, status: Bool) {

    prepare(acct: AuthAccount) {
        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeMetadataStatus(mid: mid, status: status)
        log("Change Metadata Status")
    }
}
