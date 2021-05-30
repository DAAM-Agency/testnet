// change_copyright.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(id: UInt64, /*copyright: DAAM.CopyrightStatus*/) {

    prepare(acct: AuthAccount) {
        let copyright = DAAM.CopyrightStatus.VERIFIED

        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeCopyright(id: id, copyright: copyright)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Copyright Changed")
    }
}// transaction
