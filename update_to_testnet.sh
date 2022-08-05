# Emulator to Testnet Address Update
grep -rl f8d6e0586b0a20c7 --exclude-dir='.*' | xargs sed -i 's|f8d6e0586b0a20c7|631e88ae7f1d7c20|g' # NFT & MetadataView Contracts
grep -rl ee82856bf20e2aa6 --exclude-dir='.*' | xargs sed -i 's|ee82856bf20e2aa6|9a0766d93b6608b7|g' # FT Contract
grep -rl 192440c99cb17282 --exclude-dir='.*' | xargs sed -i 's|192440c99cb17282|ba1132bc08f82fe2|g' # Profile Contract
grep -rl fd43f9148d4b725d --exclude-dir='.*' | xargs sed -i 's|fd43f9148d4b725d|a4ad5ea5c0bd2fba|g' # Categories Contract
grep -rl fd43f9148d4b725d --exclude-dir='.*' | xargs sed -i 's|fd43f9148d4b725d|a4ad5ea5c0bd2fba|g' # DAAM Contract
grep -rl 0ae53cb6e3f42a79 --exclude-dir='.*' | xargs sed -i 's|0ae53cb6e3f42a79|7e60df042a9c0868|g' # Flow Token

echo "Manual Edit of FUSD, share same address of Profile"
grep -rn "import FUSD" --exclude-dir='.*'

#grep -rl --exclude-dir='.*' | xargs sed -i 's|||g' # 
