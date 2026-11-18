# memesis

> *When memory becomes your nemesis, use `memesis` for that mem-assist.*

`memesis` is a modern, opinionated CLI memory diagnostic tool for Linux. It provides a high-level summary of memory, grouped by assignment and evictability.

## Relationship to `smem`

The default, high-level summary provided by `memesis` was inspired by `smem -tw`.

However, it makes some improvements upon `smem`:
* Support for the modern `KReclaimable` (see [upstream fix attempt](contrib/smem/README.md)).
* Support for explicit memory pools like `Zswap` and `Hugetlb`.
* Retains only actionable rows.

## Design Decisions

`memesis` uses the following schema:

### Columns (Evictability)

* **Allocated:** The total footprint of this assignment class.
* **Reclaimable:** Memory which is safe to drop under pressure (e.g. page cache, buffers).
* **Committed:** Memory which cannot be dropped without data loss or swap.

### Rows (Assignment)

* **kernelspace pool:** The static pool assignments for the kernel (Zswap).
* **kernelspace:** The dynamic assignments of the kernel (Slab, KReclaimable, Buffers, kernelspace Cached).
* **userspace pool:** The static pool assignments for user applications (Hugetlb).
* **userspace:** The dynamic assignments of user applications (AnonPages, Mapped).
* **free:** Unassigned, unallocated memory.

## Usage

`memesis` is currently a standalone `bash` prototype. It safely parses `/proc/meminfo` with backwards compatibility for older kernels.

```bash
$ ./memesis.sh
Assignment          Allocated   Reclaimable  Committed
kernelspace pool       450000             0     450000
kernelspace           3100000       2000000    1100000
userspace pool        8000000             0    8000000
userspace             2045360        659800    1385560
free                  1152004       1152004          0
------------------------------------------------------
total                14747364       3811804   10935560

```

## Future

This `bash` script validates the math and captures the high-level architectural view.

As time permits:
* `memesis` will be rebuilt in a compiled language (likely Rust) to improve performance and portability.
* Additional memory information will be parsed from procfs (`meminfo`, `slabinfo`, etc.) and sysfs allowing for granular drill-down views. These views will prioritize surfacing actionable information for while troubleshooting memory leaks and memory hogs.
