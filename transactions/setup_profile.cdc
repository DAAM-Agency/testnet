// setup_profile.cdc

import Profile from 0x192440c99cb17282

transaction {
  let address: Address
  prepare(acct: AuthAccount) {
    self.address = acct.address
    if !Profile.check(self.address) {
      acct.save(<- Profile.new(), to: Profile.privatePath)
      acct.link<&Profile.Base{Profile.Public}>(Profile.publicPath, target: Profile.privatePath)
    }
  }
  post {
    Profile.check(self.address): "Account was not initialized"
  }
}