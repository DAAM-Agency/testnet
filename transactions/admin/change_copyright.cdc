// change_copyright.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(metadataID: UInt64, /*copyright: DAAM.CopyrightStatus*/) {

    prepare(acct: AuthAccount) {
        let copyright = DAAM.CopyrightStatus.VERIFIED

        let admin = acct.borrow<&DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeCopyright(mid: metadataID, copyright: copyright)
        log("Copyright Changed")
    }
}// transaction
