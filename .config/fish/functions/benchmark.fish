function benchmark --wraps='hyperfine --runs 5 --warmup 5 --shell fish' --description 'alias benchmark=hyperfine --runs 5 --warmup 5 --shell fish'
    hyperfine --runs 20 --warmup 5 --shell fish $argv
end
