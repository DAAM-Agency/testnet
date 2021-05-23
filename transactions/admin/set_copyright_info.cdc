// set_copyright_info.cdc

import DAAM          from 0xfd43f9148d4b725d
import DAAMCopyright from 0xe03daebed8ca0615

transaction(tokenID: UInt64, copyright: DAAMCopyright.CopyrightStatus) {
    //let copyright: DAAMCopyright.CopyrightStatus

    prepare(acct: AuthAccount) {
        //self.copyright = DAAMCopyright.CopyrightStatus.VERIFIED
        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        admin.setCopyrightInformation(tokenID: tokenID, copyright: copyright)     
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Copyright Reset for NFT: ".concat(tokenID.toString()) )
    }
}