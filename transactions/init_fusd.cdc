// init_FUSD.cdc

transaction(name: String, code: String) {
    let name  : String
    let code  : String
    let signer: AuthAccount

    prepare(signer: AuthAccount) {
        self.name   = name
        self.code   = code
        self.signer = signer
    }
    execute {
        self.signer.contracts.add(name: self.name, code: self.code.decodeHex(), self.signer)
    }
}
