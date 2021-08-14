// init_FUSD.cdc

transaction(name: String, code: String) {
    let name  : String
    let agency: Address
    let cto   : Address
    let code  : String
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.name   = name
        self.agency = agency
        self.cto    = cto
        self.code   = code
        self.signer = signer
    }

    execute {
        self.signer.contracts.add(name: self.name, code: self.code.decodeHex(), self.signer)
    }
}
// flow transactions send ../testnet_keys/init_DAAM_Agency.cdc --arg String:"DAAM -- arg String:$CODE --arg Address:$AGENCflow transactions send ../testnet_keys/init_DAAM_Agency.cdc --arg String:"DAAM -- arg String:$CODE --arg Address:$AGENCY --arg Address:$FOUNDERY --arg Address:$FOUNDER