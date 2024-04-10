# filplus-test-env

## Quick start

```
docker compose up -d
```

## Recreate from scratch

```
docker compose down -v && docker compose up -d
```

## Connecting to Lotus API

Lotus API is exposed on `localhost:1234`. EVM APIs are enabled. Use `get-token.sh` tool to get Authorization token. It's passed through a proxy that sets permissive CORS headers, so should be usable on any FE with no issues.

## Connecting to filplus-backend

TBD

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