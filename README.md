## instructions
- `preprocess.jl` downloads the `.xlsx` datafile from `https://mappingpoliceviolence.org/` and generates `.csv` files of processed/formatted datafiles (`state_strings.csv` and `city_strings.csv`)
- `state_strings.csv` and `city_strings.csv` datafiles contain processed key-value pairs; the data can be loaded into a dictionary `D` and then accessed like `D["Chicago"]` or `D["Florida"]` to return a formatted / printable string

## to generate datafiles (optional)
0. download [`julia`](https://julialang.org/downloads/)
1. run `$ julia preproces.jl` from terminal

## mini-example
0. run `$ julia example.jl` from terminal to show example output
