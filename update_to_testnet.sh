# Emulator to Testnet Address Update
grep -rl 631e88ae7f1d7c20 --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's|631e88ae7f1d7c20|631e88ae7f1d7c20|g' # NFT & MetadataView Contracts
grep -rl 9a0766d93b6608b7 --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's|9a0766d93b6608b7|9a0766d93b6608b7|g' # FT Contract
grep -rl ba1132bc08f82fe2 --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's|ba1132bc08f82fe2|ba1132bc08f82fe2|g' # Profile Contract
grep -rl a4ad5ea5c0bd2fba --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's|a4ad5ea5c0bd2fba|a4ad5ea5c0bd2fba|g' # Categories Contract
grep -rl a4ad5ea5c0bd2fba --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's|a4ad5ea5c0bd2fba|a4ad5ea5c0bd2fba|g' # DAAM_V21 Contract
grep -rl 7e60df042a9c0868 --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's|7e60df042a9c0868|7e60df042a9c0868|g' # Flow Token

grep -rl " DAAM" --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's| DAAM| DAAM_V21|g' # 
grep -rl 'DAAM\.' --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's|DAAM.|DAAM_V21.|g' # 

grep -rl AuctionHouse --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's|AuctionHouse|AuctionHouse_V14|g' # 

echo "Manual Edit of FUSD, share same address of Profile"
grep -rn "import FUSD" --exclude-dir='.*' --exclude={*.sh,*.md} 

echo "Manually verify borrowDAAM does not get renamed"
grep -rn "borrowDAAM" --exclude-dir='.*' --exclude={*.sh,*.md} 

echo "Manully Remove TokenA"
grep -rn TokenA --exclude={*.sh,*.md} --exclude-dir=.*

echo "Manully Remove TokenB"
grep -rn ' TokenB' --exclude={*.sh,*.md} --exclude-dir=.*

rm ./transactions/init_DAAM_Agency.cdc
#grep -rl --exclude-dir='.*' --exclude={*.sh,*.md} | xargs sed -i 's|||g' # 
