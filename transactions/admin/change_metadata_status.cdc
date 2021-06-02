// change_metadata_status.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(metadataID: UInt64, status: Bool) {

    prepare(acct: AuthAccount) {
        let copyright = DAAM.CopyrightStatus.VERIFIED

        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changMetadataStatus(mid: metadataID, status: status)
        log("Change Metadata Status")
    }
}// transaction
