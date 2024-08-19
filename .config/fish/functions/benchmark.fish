function benchmark --wraps=hyperfine --description 'Benchmarking Function Using Hyperfine'
    if type -q hyperfine
        hyperfine --warmup 10 --runs 100 $argv
    else
        echo "Hyperfine is not installed, please install to use benchmark"
    end
end
