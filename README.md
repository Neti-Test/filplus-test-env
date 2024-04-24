# filplus-test-env

## Quick start

First configure it:
* copy `.env.example` to `.env` and modify as needed
* put GitHub App Private key in `gh-private-key.pem` file

And then run it:

```
git submodule update --init --recursive
docker compose up -d
```

And populate database with allocators & applications:

```
./tools/init-allocators.sh
```

And then:

```
./tools/create-application.sh ISSUE_NUMBER
```

where ISSUE_NUMBER is a fresh issue from [bookkeeping repo](https://github.com/Neti-Test/filplus-bookkeeping-msig-contract/issues).

## Recreate from scratch

```
docker compose down -v && docker compose up -d
```

## Connecting to Lotus API

Lotus API is exposed on `localhost:1234`. EVM APIs are enabled. Use `get-token.sh` tool to get Authorization token. It's passed through a proxy that sets permissive CORS headers, so should be usable on any FE with no issues.

Example:

```
cast bn --rpc-url http://localhost:1234/rpc/v1
```

## Connecting to filplus-backend

Backend is exposed on `localhost:8081`. Example:

```
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

## Tools

```
./tools/lotus.sh
```

Run lotus command

```
./tools/lotus-shed.sh
```

Run lotus-shed command

```
./tools/info.sh
```

List verifiers and clients

```
./tools/add-verifier.sh verifierAddress
```

Add new verifier (a.k.a. allocator; a.k.a. notary)

```
./tools/grant_datacap.sh verifierAddress clientAddress dataCapAmount
```

Grant datacap to clien

```
./tools/get-token.sh
```

Fetch API token
