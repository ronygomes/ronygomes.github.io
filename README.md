# ronygomes.github.io

My own fraction on the Web where I store my thoughts and learning. I am neither a good writer nor enjoy writing. This blog exists only to remind me how much I have grown when frustration strikes for my mediocrity.

This repository is deployed at <a target="_blank" href="https://www.ronygomes.me">www.ronygomes.me</a>.

## Run Locally

Execute following commands and it will be deloyed in
* Mac: http://docker.for.mac.localhost:4000
* Linux: http://localhost:4000

```shell
$ git clone https://github.com/ronygomes/ronygomes.github.io.git blog
$ cd blog && docker build . -t ronygomes/blog

$ docker run -it -p 4000:4000 \
    --mount type=bind,source="$(pwd)"/,target=/blog \
    ronygomes/blog jekyll serve -H 0.0.0.0
```

## Resources

* [Kramdown Syntax](https://kramdown.gettalong.org/syntax.html)
* [GitHub Markdown Syntax](https://docs.github.com/en/github/writing-on-github/basic-writing-and-formatting-syntax)
* [GitHub Pages Dependency versions](https://pages.github.com/versions/)
