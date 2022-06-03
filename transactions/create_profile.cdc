// create_profile.cdc

import Profile from 0xba1132bc08f82fe2

transaction {
  let address: Address
  prepare(acct: AuthAccount) {
    self.address = acct.address
    if !Profile.check(self.address) {
      acct.save(<- Profile.new(), to: Profile.privatePath)
      acct.link<&Profile.Base{Profile.Public}>(Profile.publicPath, target: Profile.privatePath)
      
      var logmsg = self.address.toString()
      logmsg.concat(" has created a Profile")
      log(logmsg)
    }
  }
  post {
    Profile.check(self.address): "Account was not initialized"
  }
}
