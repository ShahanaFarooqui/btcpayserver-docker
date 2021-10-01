#!/bin/bash

function display_help () {
cat <<-END
Usage:
------

Tooling to setup your joinmarket yield generator

    exec: Run the specified joinmarket script
    wallet-tool: Run wallet-tools.py on the wallet
    wallet-tool-generate: Generate a new wallet
    set-wallet: Set the wallet that the yield generator need to use
    logs: See logs of the yield generator (add -f to follow the logs)
    bash: Open an interactive bash session in the joinmarket container
    receive-payjoin: Receive a payjoin payment (this will stop the yield generator until the payment is received)
    sendpayment: Send a payjoin through coinjoin (password needed, this will stop the yield generator until the payment is received)
    start: Start the yield generator (started by default)
    stop: Stop the yield generator

Example:
    * jm.sh wallet-tool-generate
    * jm.sh set-wallet wallet.jmdat mypassword
    * jm.sh wallet-tool
    * jm.sh receive-payjoin
    * jm.sh sendpayment <address> <amount>
    * jm.sh wallet-tool history
    * jm.sh logs -f
    * jm.sh bash
    * jm.sh start
    * jm.sh stop

See https://github.com/btcpayserver/btcpayserver-docker/tree/master/docs/joinmarket.md for more information.
END
}

while (( "$#" )); do
  case "$1" in
    exec)
      CMD="$1"
      shift 1
      break;
      ;;
    logs)
      CMD="$1"
      shift 1
      break;
      ;;
    bash)
      CMD="$1"
      shift 1
      break;
      ;;
    wallet-tool)
      CMD="$1"
      shift 1
      break;
      ;;
    set-wallet)
      CMD="$1"
      shift 1
      break;
      ;;
    receive-payjoin)
      CMD="$1"
      shift 1
      break;
      ;;
    sendpayment)
      CMD="$1"
      shift 1
      break;
      ;;
    wallet-tool-generate)
      CMD="$1"
      shift 1
      break;
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      display_help
      return
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

if ! [[ "$CMD" ]]; then
    display_help
else
    if [[ "$CMD" == "wallet-tool" ]]; then
        docker exec joinmarket exec-wrapper.sh unlockwallet wallet-tool.py "$@"
    elif [[ "$CMD" == "wallet-tool-generate" ]]; then
        docker exec -ti joinmarket exec-wrapper.sh wallet-tool.py generate "$@"
    elif [[ "$CMD" == "sendpayment" ]]; then
        docker exec -ti joinmarket exec-wrapper.sh unlockwallet nopass sendpayment.py "$@"
    elif [[ "$CMD" == "receive-payjoin" ]]; then
        docker exec -ti joinmarket exec-wrapper.sh unlockwallet receive-payjoin.py "$@"
    elif [[ "$CMD" == "set-wallet" ]]; then
        docker exec joinmarket set-wallet.sh "$@"
        docker restart joinmarket
    elif [[ "$CMD" == "bash" ]]; then    
        docker exec -ti joinmarket exec-wrapper.sh bash "$@"
    else
        display_help
    fi
fi
