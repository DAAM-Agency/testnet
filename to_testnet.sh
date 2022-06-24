# emulator addresses
# FlowToken        : 0x0ae53cb6e3f42a79
# NonFungibleToken : 0xf8d6e0586b0a20c7
# FungibleToken    : 0xee82856bf20e2aa6 
# MetadataViews    : 0xf8d6e0586b0a20c7
# Profile          : 0x192440c99cb17282
# Categories       : 0xfd43f9148d4b725d
# DAAM             : 0xfd43f9148d4b725d
# FUSD             : 0x192440c99cb17282

# testnet addresses
# FlowToken        : 0x7e60df042a9c0868
# NonFungibleToken : 0x631e88ae7f1d7c20
# FungibleToken    : 0x9a0766d93b6608b7 
# MetadataViews    : 0x631e88ae7f1d7c20
# Profile          : 0xba1132bc08f82fe2
# Categories       : 0xa4ad5ea5c0bd2fba
# DAAM             : 0xa4ad5ea5c0bd2fba
# FUSD             : 0xe223d8a629e49c68

grep -rl 0x0ae53cb6e3f42a79 --exclude-dir='.*' --exclude='*.sh' | xargs sed -i 's|0x0ae53cb6e3f42a79|0x7e60df042a9c0868|g' # FlowToken
grep -rl 0xf8d6e0586b0a20c7 --exclude-dir='.*' --exclude='*.sh' | xargs sed -i 's|0xf8d6e0586b0a20c7|0x631e88ae7f1d7c20|g' # NonFungibleToken & MetadataViews
grep -rl 0xee82856bf20e2aa6 --exclude-dir='.*' --exclude='*.sh' | xargs sed -i 's|0xee82856bf20e2aa6|0x9a0766d93b6608b7|g' # FungibleToken
grep -rl 0xfd43f9148d4b725d --exclude-dir='.*' --exclude='*.sh' | xargs sed -i 's|0xfd43f9148d4b725d|0xa4ad5ea5c0bd2fba|g' # DAAM & Categories

grep -rl 0x192440c99cb17282  --exclude-dir={.*,contracts} --exclude='*.sh' --exclude='*profile*' | xargs sed -i 's|0x192440c99cb17282|0xe223d8a629e49c68|g' # FUSD
grep -rl 0x192440c99cb17282 --exclude-dir='.*' --exclude='*.sh' | xargs sed -i 's|0x192440c99cb17282|0xba1132bc08f82fe2|g' #Profile

grep -rl DAAM --exclude-dir='.*' --exclude='*.sh' | xargs sed -i 's|DAAM|DAAM_V13|g'
