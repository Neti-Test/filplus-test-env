# FIDL Filecoin Test Environment

This repository assists in setting up a test environment that's useful for:

* development of Allocator.tech
* development of apply.allocator.tech
* development of smart contracts for Fil+

## Quick start

Make sure you have installed:

* [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/)
* git, [jq](https://jqlang.org/) - should be available in your distro repos, try `apt install git jq`
* [Foundry](https://getfoundry.sh/)
* Node.js and npm (recommended version 22, but should work on any 18+)

```bash
git submodule update --init --recursive
docker compose up -d
```

### Apply.allocator.tech specific steps

Use `add-rkh.sh` script to add your wallet(s) as RKHs:

```bash
./tools/add-rkh.sh fvmSignerAddress
```

Use `deploy-safe.sh` script to deploy a Safe account that can be used as a Metaallocator owner:

```bash
./tools/deploy-safe.sh evmSignerAddress
```

Use `deploy-metaallocator-with-datacap.sh` script to deploy a new Metaallocator:

```bash
./tools/deploy-metaallocator-with-datacap.sh fvmOwnerAddress


Tip: use `lotus evm stat` to convert between FVM/EVM addresses:

```bash
./tools/lotus.sh evm stat anyAddress
```

### Allocator.tech specific steps

First configure it:

* copy `.env.example` to `.env` and modify as needed
* put GitHub App Private key in `gh-private-key.pem` file

Run it:

```bash
docker compose --profile allocator-tech up -d

```

Populate database with allocators & applications:

```bash
./tools/init-allocators.sh
```

Import issue from bookkeeping repo to database:

```bash
./tools/create-application.sh ISSUE_NUMBER
```

where ISSUE_NUMBER is a fresh issue from [bookkeeping repo](https://github.com/Neti-Test/filplus-bookkeeping-msig-contract/issues).

## Recreate from scratch

```bash
docker compose --profile "*" down -v && docker compose up -d
```

## Connecting to Lotus API

Lotus API is exposed on `localhost:1234`. EVM APIs are enabled. Use `get-token.sh` tool to get Authorization token. It's passed through a proxy that sets permissive CORS headers, so should be usable on any FE with no issues.

Example:

```bash

cast bn --rpc-url localhost:1234/rpc/v1

```

## Connecting to filplus-backend

Backend is exposed on `localhost:8081`. Example:

```bash

curl localhost:8081/allocators | jq

```

## Smart Contract Allocator

Out of the box there's one Allocator contract deployed, owned by `0x50c4c4551974c248e8e1c64060c8a3342fdb22d6` (privkey `0x26757a7491f72e1dd8becdc611a87db2f30f0c084155ed9e57ef6737a2026101`) under address `0x640bD4be149f40714D95aBcD414338bc7CfF39a3`, a.k.a. `t410fmqf5jpqut5ahctmvvpgucqzyxr6p6ond6pqephq`, used for Msig Contract Allocator

* msig `t2xdirjkq5p6mwqsfvwsyjytkazpvdlvo3snb7pwi` has allowance granted out of the box, with following signers:
  * `t17dx5t567wz5ues2cjkh5mor36nwxysnd5dugpey`
  * `t1roygqfjkssnfhz3xtfglikg4olckyjrl5ftlqmi`
  * `t1sqwwp3q537tgztr6maqjabhqyouu7uoycmsts7i`
  * `t1cbfxphkqhworbuugpkrhayxo2dumf5zjjyy677y`

There's also Factory contract deployed under address `0xb49f2FA2026373353f6DD033d5132e1Eabe94843`. Predeployed allocator contract isn't registered in it.

See also `deploy-metaallocator-with-datacap.sh` script if you need to deploy a new instance of the Allocator contract using the factory.

## Tools

```bash

./tools/lotus.sh

```

Run lotus command

```bash

./tools/lotus-shed.sh

```

Run lotus-shed command

```bash

./tools/info.sh

```

List verifiers and clients

```bash

./tools/add-verifier.sh verifierAddress

```

Add new verifier (a.k.a. allocator; a.k.a. notary)

```bash

./tools/grant_datacap.sh verifierAddress clientAddress dataCapAmount

```

Grant datacap to a client

```bash

./tools/get-token.sh

```

Fetch API token

```bash
./tools/add-rkh.sh signerAddress
```

Add a new signer (RKH) to f080 multisig.

```bash
./tools/deploy-metaallocator-with-datacap.sh ownerAddress
```

Deploy a new Metaallocator contract, owned by `ownerAddress`, and give it 100 PiB of DC.

```bash
./tools/deploy-safe.sh signerAddress
```

Deploy a new Safe account, with threshold 1, and one signer `signerAddress`. Expects EVM format.
