# Stata-misc


Miscellaneous data programs for Stata

- `capdrop`, `capkeep` and `capds` correspond respectively to `drop`, `keep` and `ds` except that no error is returned when some variable is not present in the dataset (while the command still applies to variables in the dataset)
- `sorder` is a wrapper for `sort ; order`
- `fillall` is a version of `fillin` that accepts multiple variables for `id` (`fillall` generates rows for each combination of `id1` x `id2` in the original dataset)

	```
	fillall, id1(var1 var2) id2(var3)
	```

- `tsfillall` is a version of `tsfill` that accepts multiple variables for `id` (`tsfill` generates rows for missing period within groups defined by `id`)

	```
	tsfillall id1 id2 time
	```


