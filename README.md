# ninja-flame

Small script to convert [ninja](https://github.com/ninja-build/ninja) build times from the `.ninja_log` to a format suitable to generate flamegraphs.
Pipe the output into [flamegraph.pl](https://github.com/brendangregg/FlameGraph), [inferno-flamegraph](https://github.com/jonhoo/inferno),
or store it in a file and loaded it with [Firefox Profiler](https://profiler.firefox.com) or [Perfetto](https://ui.perfetto.dev/).

    # Build your project
    $ ninja -C ./build -j 1

    $ ninja-flame.sh ./build/.ninja_log | flamegraph.pl > build-flame.svg

Just some awk.
