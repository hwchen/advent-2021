profile-fast day:
    zig build -Drelease-fast
    sudo perf record -F 5000 --call-graph dwarf zig-out/bin/day{{day}}
    sudo perf report
