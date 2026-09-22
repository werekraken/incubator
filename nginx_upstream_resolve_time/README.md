# NGINX `$upstream_resolve_time`

[This patch](nginx-1.31.6-1.el9.ngx.src/SOURCES/1001-Capture-and-expose-upstream_resolve_time.patch) adds `$upstream_resolve_time`.

* `$upstream_resolve_time`:
    - exposes the duration spent resolving hostnames of upstreams.
    - is `-` when nothing needed resolving.
    - is `""` on errors before resolving (matching the behavior of `$upstream_{response,connect,header}_time`).
* `$upstream_{response,connect,header}_time`:
    - are now `-` on errors while resolving.
    - remain `""` on errors before resolving.

## Results

### Patched

```
     upstream_*_time
reso.  resp.  conn.  head.  stat.  error
""     ""     ""     ""     502    "no resolver defined to resolve <hostname>"
0.023  -      -      -      502    "<hostname> could not be resolved (3: Host not found)"
0.104  -      -      -      502    "<hostname> could not be resolved (2: Server failure)"
0.995  -      -      -      499    client closed request while resolving <hostname>
3.003  -      -      -      502    "<hostname> could not be resolved (110: Operation timed out)"
0.024  0.000  -      -      500    "bind(<ipaddr>) failed (99: Cannot assign requested address) while connecting to upstream"
-      0.000  -      -      502    "connect() failed (111: Connection refused) while connecting to upstream"
-      0.995  -      -      499    client closed request while connecting to upstream
-      3.002  -      -      504    "upstream timed out (110: Connection timed out) while connecting to upstream"
0.000  0.048  0.024  -      502    "upstream prematurely closed connection while reading response header from upstream"
0.021  0.975  0.068  -      499    client closed request while reading response header from upstream
0.021  3.068  0.065  -      504    "upstream timed out (110: Connection timed out) while reading response header from upstream"
0.024  0.098  0.025  0.098  200    OK

                upstream_*_time
reso.        resp.            conn.            head.            stat.  error
"- : 0.026"  "0.000 : 0.100"  "0.000 : 0.023"  "0.000 : 0.100"  200    OK
```

### Vanilla (baseline)
```
  upstream_*_time
resp.  conn.  head.  stat.  error
""     ""     ""     502    "no resolver defined to resolve <hostname>"
""     ""     ""     502    "<hostname> could not be resolved (3: Host not found)"
""     ""     ""     502    "<hostname> could not be resolved (2: Server failure)"
""     ""     ""     499    client closed request while resolving <hostname>
""     ""     ""     502    "<hostname> could not be resolved (110: Operation timed out)"
0.000  -      -      500    "bind(<ipaddr>) failed (99: Cannot assign requested address) while connecting to upstream"
0.000  -      -      502    "connect() failed (111: Connection refused) while connecting to upstream"
0.997  -      -      499    client closed request while connecting to upstream
3.004  -      -      504    "upstream timed out (110: Connection timed out) while connecting to upstream"
0.047  0.023  -      502    "upstream prematurely closed connection while reading response header from upstream"
0.997  0.068  -      499    client closed request while reading response header from upstream
3.069  0.066  -      504    "upstream timed out (110: Connection timed out) while reading response header from upstream"
0.098  0.024  0.098  200    OK

     upstream_*_time
resp.            conn.            head.            stat.  error
"0.000 : 0.104"  "0.000 : 0.024"  "0.000 : 0.104"  200    OK
```

### Comparison

```
              upstream_*_time
variant  reso.  resp.  conn.  head.  stat.  error

vanilla         ""     ""     ""     502    "no resolver defined to resolve <hostname>"
patched  ""     ""     ""     ""     502    "no resolver defined to resolve <hostname>"

vanilla         ""     ""     ""     502    "<hostname> could not be resolved (3: Host not found)"
patched  0.023  -      -      -      502    "<hostname> could not be resolved (3: Host not found)"

vanilla         ""     ""     ""     502    "<hostname> could not be resolved (2: Server failure)"
patched  0.104  -      -      -      502    "<hostname> could not be resolved (2: Server failure)"

vanilla         ""     ""     ""     499    client closed request while resolving <hostname>
patched  0.995  -      -      -      499    client closed request while resolving <hostname>

vanilla         ""     ""     ""     502    "<hostname> could not be resolved (110: Operation timed out)"
patched  3.003  -      -      -      502    "<hostname> could not be resolved (110: Operation timed out)"

vanilla         0.000  -      -      500    "bind(<ipaddr>) failed (99: Cannot assign requested address) while connecting to upstream"
patched  0.024  0.000  -      -      500    "bind(<ipaddr>) failed (99: Cannot assign requested address) while connecting to upstream"

vanilla         0.000  -      -      502    "connect() failed (111: Connection refused) while connecting to upstream"
patched  -      0.000  -      -      502    "connect() failed (111: Connection refused) while connecting to upstream"

vanilla         0.997  -      -      499    client closed request while connecting to upstream
patched  -      0.995  -      -      499    client closed request while connecting to upstream

vanilla         3.004  -      -      504    "upstream timed out (110: Connection timed out) while connecting to upstream"
patched  -      3.002  -      -      504    "upstream timed out (110: Connection timed out) while connecting to upstream"

vanilla         0.047  0.023  -      502    "upstream prematurely closed connection while reading response header from upstream"
patched  0.000  0.048  0.024  -      502    "upstream prematurely closed connection while reading response header from upstream"

vanilla         0.997  0.068  -      499    client closed request while reading response header from upstream
patched  0.021  0.975  0.068  -      499    client closed request while reading response header from upstream

vanilla         3.069  0.066  -      504    "upstream timed out (110: Connection timed out) while reading response header from upstream"
patched  0.021  3.068  0.065  -      504    "upstream timed out (110: Connection timed out) while reading response header from upstream"

vanilla         0.098  0.024  0.098  200    OK
patched  0.024  0.098  0.025  0.098  200    OK



                       upstream_*_time
variant  reso.        resp.            conn.            head.            stat.  error

vanilla               "0.000 : 0.104"  "0.000 : 0.024"  "0.000 : 0.104"  200    OK
patched  "- : 0.026"  "0.000 : 0.100"  "0.000 : 0.023"  "0.000 : 0.100"  200    OK
```

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
