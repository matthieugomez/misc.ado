# Stata-misc


Miscellaneous data programs for Stata

- `clean` winsorizes based on 5 interquartile
- `capdrop` and `capkeep` corresponds to `drop` and `keep`, except no error is returned when some variable is not present in the dataset (while the command still applies to variables in the dataset)
- `sorder` is `sort ; order`
- `append2` is just like `append`, except that it handles variables with conflicting types (numeric vs string), coercing everything to string
- `fillall` is a version of `fillin` that accepts multiple variables for `id` or `time`.
