# Stata-misc


Miscellaneous data programs for Stata

- `clean` winsorizes based on 5 interquartiles by default, or alternatively with respect to given percentiles.
- `capdrop`, `capkeep` and `capds` correspond respectively to `drop`, `keep` and `ds` except that no error is returned when some variable is not present in the dataset (while the command still applies to variables in the dataset)
- `sorder` is a wrapper for `sort ; order`
- `capappend` is just like `append`, except that it handles variables with conflicting types (numeric vs string), coercing everything to string
- `fillall` is a version of `fillin` that accepts multiple variables for `id` or `time`.
