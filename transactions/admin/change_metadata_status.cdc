// change_metadata_status.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(mid: UInt64, status: Bool) {

    prepare(acct: AuthAccount) {
        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeMetadataStatus(mid: mid, status: status)
        log("Change Metadata Status")
    }
}
