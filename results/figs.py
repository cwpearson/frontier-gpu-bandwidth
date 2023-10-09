from pathlib import Path
import json
from dataclasses import dataclass

import numpy as np
import matplotlib.pyplot as plt

RESULTS_DIR = Path(__file__).parent

## Read all data
data = {}
for e in RESULTS_DIR.iterdir():
    if e.suffix != ".json":
        continue

    print(f'load {e}')
    with open(e, 'r') as f:
        try:
            res = json.load(f)
        except json.decoder.JSONDecodeError as e:
            print(f"SKIP - incorrect formatting")
            continue

    benchmarks = res["benchmarks"]
    for benchmark in benchmarks:
        run_type = benchmark["run_type"]

        if run_type == "iteration":

            run_name = benchmark["run_name"]

            if "Comm_prefetch_managed_GPUToGPU/0/0" in run_name:
                continue
            elif "/0/0/" in run_name:
                continue

            xs, ys = data.get(run_name, ([],[]))
            ys += [benchmark["real_time"]]
            xs += [int(benchmark["bytes"])]
            data[run_name] = (xs, ys)

## compute aggregates
for name, (xs, ys) in data.items():
    assert all(xs[0] == x_i for x_i in xs)
    b = xs[0] # bytes
    times = ys
    bws = [b / y for y in ys]

    times_mean = np.mean(times)
    times_stddev = np.std(times)

    bws_mean = np.mean(bws)
    bws_stddev = np.std(bws)

    data[name] = (b, times_mean, times_stddev, bws_mean, bws_stddev)

## split data by name
series = {}
for name, point in data.items():
    name, f1, f2 = name.split("/")[0:3]
    # expect these to be ints
    f1 = int(f1)
    f2 = int(f2)
    name = "/".join((name, str(f1), str(f2)))

    s = series.get(name, [])
    s += [point]
    series[name] = s

# sort all series
for name, points in series.items():
    series[name] = sorted(points, key=lambda p: p[0])

# split to x,t, terr, bw, bwerr
for name, points in series.items():
    # [(x,y,z), ...] -> ([x...], [y...], [z...])
    x, t, terr, bw, bwerr = zip(*points) 
    series[name] = (x, t, terr, bw, bwerr)
# print(series)

for name, (x, t, terr, bw, bwerr) in series.items():
    plt.errorbar(x, bw, yerr=bwerr, label=name)


for pattern in [
    "hipManaged_HostToGPUWriteDst",
    "hipMemcpyAsync_GPUToGPU",
    "hipMemcpyAsync_GPUToPageable",
    "hipMemcpyAsync_GPUToPinned",
    "implicit_managed_GPURdHost_coarse",
    "implicit_managed_GPURdHost_fine",
    "implicit_managed_GPUWrGPU_coarse",
    "implicit_managed_GPUWrGPU_fine",
    "implicit_mapped_GPURdHost",
    "prefetch_managed_GPUToGPU",
    "prefetch_managed_GPUToHost",
]:
    plt.clf()
    for name, (x, t, terr, bw, bwerr) in series.items():
        if pattern not in name:
            continue
        plt.errorbar(x, bw, yerr=bwerr, label=name)    
    output_path = f"{pattern}.pdf"
    print(f"write {output_path}")
    plt.xscale('log')
    lgd = plt.legend(bbox_to_anchor=(1.04, 1))
    plt.tight_layout()
    plt.savefig(output_path, bbox_extra_artists=(lgd,), bbox_inches='tight')