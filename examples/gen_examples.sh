set -v
set -e
cd `dirname $0`
./oscribblec.sh -d ./fase16/adder ./fase16/adder/Adder.scr -ocamlapi Adder
./oscribblec.sh -d ./fase16/smtp ./fase16/smtp/Smtp.scr -ocamlapi Smtp
./oscribblec.sh -d ./others/math ./others/math/Math.scr -ocamlapi MathService
./oscribblec.sh -d ./others/rpc ./others/rpc/RPC.scr -ocamlapi RPC
./oscribblec.sh -d ./others/rpc ./others/rpc/RPC.scr -ocamlapi Proto
./oscribblec.sh -d ./others/rpc ./others/rpc/RPC.scr -ocamlapi RPCComp
./oscribblec.sh -d ./others/rpc ./others/rpc/RPC.scr -ocamlapi Relay
./oscribblec.sh -d ./others/rpc ./others/rpc/RPC.scr -ocamlapi RPCComp2
./oscribblec.sh -d ./others/rpc ./others/rpc/RPC.scr -ocamlapi MyRelay
./oscribblec.sh -d ./others/loan ./others/loan/LoanApplication.scr -ocamlapi BuyerBrokerSupplier
./oscribblec.sh -d ./others/loan ./others/loan/LoanApplication.scr -ocamlapi BBSOriginal
./oscribblec.sh -d ./others/game1 ./others/game1/Game1.scr -ocamlapi Game
./oscribblec.sh -d ./others/game1 ./others/game1/Game1.scr -ocamlapi Game1Proto
./oscribblec.sh -d ./others/game2 ./others/game2/Game2.scr -ocamlapi Game2Proto
./oscribblec.sh -d ./others/threebuyer ./others/threebuyer/ThreeBuyer.scr -ocamlapi TwoBuyer
./oscribblec.sh -d ./others/threebuyer ./others/threebuyer/ThreeBuyer.scr -ocamlapi TwoBuyerChoice
./oscribblec.sh -d ./others/threebuyer ./others/threebuyer/ThreeBuyer.scr -ocamlapi ThreeBuyer
./oscribblec.sh -d ./others/travel ./others/travel/Travel.scr -ocamlapi Travel
./oscribblec.sh -d ./fase17/travel1 ./fase17/travel1/Travel1.scr -ocamlapi Travel1
./oscribblec.sh -d ./fase17/travel2 ./fase17/travel2/Travel2.scr -ocamlapi Travel2
# ./oscribblec.sh -d ./fase17/travel3 ./fase17/travel3/Travel3.scr -ocamlapi Travel3
# ./oscribblec.sh -d ./fase17/appD ./fase17/appD/AppD.scr -ocamlapi InfoAuth
