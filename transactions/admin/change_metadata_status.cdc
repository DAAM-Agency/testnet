// change_metadata_status.cdc

import DAAM from x51e2c02e69b53477

transaction(metadataID: UInt64, status: Bool) {

    prepare(acct: AuthAccount) {
        let copyright = DAAM.CopyrightStatus.VERIFIED

        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changMetadataStatus(mid: metadataID, status: status)
        log("Change Metadata Status")
    }
}// transaction
