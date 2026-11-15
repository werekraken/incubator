#!/bin/bash

set +e

declare -A meminfo

while read -r key value toss; do
  [[ "$key" =~ ^[a-zA-Z0-9]+:$ ]]

  meminfo["${key%:}"]="$value"

done < /proc/meminfo

[[ "$MEMESIS_DEBUG" == "true" ]] \
  && declare -p meminfo \
  | sed 's/)$/\n&/;s/\[/\n    &/g'

mem_total="${meminfo["MemTotal"]:-0}"
mem_free="${meminfo["MemFree"]:-0}"
anon_pages="${meminfo["AnonPages"]:-0}"
mapped="${meminfo["Mapped"]:-0}"
buffers="${meminfo["Buffers"]:-0}"
cached="${meminfo["Cached"]:-0}"
zswap="${meminfo["Zswap"]:-0}"
hugetlb="${meminfo["Hugetlb"]:-0}"
kreclaimable="${meminfo["KReclaimable"]:-${meminfo["SReclaimable"]:-0}}"

user_pool_committed="$hugetlb"
user_pool_reclaimable="0"
user_pool_allocated="$user_pool_committed"

user_committed="$anon_pages"
user_reclaimable="$mapped"
user_allocated="$((
  user_committed
  + user_reclaimable
))"

kern_pool_committed="$zswap"
kern_pool_reclaimable="0"
kern_pool_allocated="$kern_pool_committed"

kern_reclaimable="$((
  kreclaimable
  + buffers
  + cached
  - user_reclaimable
))"
kern_allocated="$((
  mem_total
  - mem_free
  - user_pool_allocated
  - user_allocated
  - kern_pool_allocated
))"
kern_committed="$((kern_allocated - kern_reclaimable))"

total_allocated="$mem_total"
total_reclaimable="$((
  kern_reclaimable
  + kern_pool_reclaimable
  + user_reclaimable
  + user_pool_reclaimable
  + mem_free
))"
total_committed="$((
  kern_committed
  + kern_pool_committed
  + user_committed
  + user_pool_committed
))"

_printf() {
  printf "%-18s %10s %12s %10s\n" "$@"
}

_printf "Assignment" "Allocated" "Reclaimable" "Committed"

[[ "$kern_pool_allocated" -gt 0 ]] \
  && _printf "kernelspace pool" "$kern_pool_allocated" "$kern_pool_reclaimable" "$kern_pool_committed"

_printf "kernelspace" "$kern_allocated" "$kern_reclaimable" "$kern_committed"

[[ "$user_pool_allocated" -gt 0 ]] \
  && _printf "userspace pool" "$user_pool_allocated" "$user_pool_reclaimable" "$user_pool_committed"

_printf "userspace" "$user_allocated" "$user_reclaimable" "$user_committed"
_printf "free" "$mem_free" "$mem_free" "0"
echo "-----------------------------------------------------"
_printf "total" "$total_allocated" "$total_reclaimable" "$total_committed"
