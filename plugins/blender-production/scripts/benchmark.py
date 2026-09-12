"""Summarize warm frame timings; estimates assume representative remaining shots."""
import argparse
import json
import math
from pathlib import Path
import statistics


def summarize(rows, remaining=None):
    valid = [r for r in rows if not r.get('existing') and isinstance(r.get('seconds'), (int, float))
             and math.isfinite(r['seconds']) and r['seconds'] > 0]
    warm = [r for r in valid if not r.get('cold')]
    def stats(items):
        values = sorted(r['seconds'] for r in items)
        if not values:
            return {'count': 0}
        return {'count': len(values), 'median_s': statistics.median(values),
                'p95_s': values[max(0, math.ceil(len(values) * .95) - 1)],
                'mean_s': statistics.mean(values)}
    groups = {}
    for r in warm:
        groups.setdefault(r.get('shot', r.get('title', 'unspecified')), []).append(r)
    totals = {}
    for r in warm:
        for k, v in r.get('timings', {}).items():
            if isinstance(v, (int, float)) and math.isfinite(v) and v >= 0:
                totals[k] = totals.get(k, 0) + v
    phase_sum = sum(totals.values())
    report = {'warm': stats(warm), 'cold': stats([r for r in valid if r.get('cold')]),
              'shots': {k: stats(v) for k, v in groups.items()},
              'phase_fraction_of_measured_phases': {k: v / phase_sum for k, v in totals.items()} if phase_sum else {},
              'excluded_rows': len(rows) - len(valid)}
    if remaining is not None:
        if remaining < 0:
            raise ValueError('Remaining count must be nonnegative')
        report['estimate_assumption'] = 'Warm sample represents remaining shots; excludes encode/QA and changing load'
        report['remaining_seconds_at_mean'] = report['warm'].get('mean_s', 0) * remaining if warm else None
    return report


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('log', type=Path)
    p.add_argument('--remaining', type=int)
    args = p.parse_args()
    rows = [json.loads(line) for line in args.log.read_text().splitlines() if line.strip()]
    print(json.dumps(summarize(rows, args.remaining), indent=2))
