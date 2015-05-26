# Stata-misc


Miscellaneous data programs for Stata

- `capdrop`, `capkeep` and `capds` correspond respectively to `drop`, `keep` and `ds` except that no error is returned when some variable is not present in the dataset (while the command still applies to variables in the dataset)
- `sorder` is a wrapper for `sort ; order`
- `fillall` is a version of `fillin` that accepts multiple variables for `id` or `time`.
