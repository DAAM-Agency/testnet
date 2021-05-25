// change_copyright.cdc

import DAAM from 0xfd43f9148d4b725d

transaction(id: UInt64, copyright: DAAM.CopyrightStatus) {

    prepare(acct: AuthAccount) {
        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.changeCopyright(id: UInt64, copyright: DAAM.CopyrightStatus)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Copyright Changed")
    }
}// transaction
