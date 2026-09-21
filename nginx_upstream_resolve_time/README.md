# NGINX `$upstream_resolve_time`

## Build and Test

Vagrant is used for a consistent build and test environment.

### Build (patched)

To spun up the environment and build:
```
./runner.sh
```

## Test (patched)

To test the most recent patched build:
```
./test.sh patched
```

## Test (vanilla)

To test the vanilla upstream build (for baseline comparison):
```
./test.sh vanilla
```

### Clean Up

To clean up the environment when done:
```
vagrant destroy
```
