# Contributing

Thanks for taking a look. This is a small project, so the process is light.

## Working on a change

1. Branch off `main`, one change per branch.
2. Keep Terraform tidy: `make fmt`, `make validate`, `make lint`.
3. Open a pull request describing what changed and why. CI runs `terraform`
   fmt/init/validate as a required check, plus tflint and a Trivy config scan.
4. PRs squash-merge once CI is green.

## Local tooling

Everything is pinned in the toolchain image:

```sh
make tools-build   # build the image
make shell         # drop into it with the repo mounted
```

You can also run Terraform directly on the host for read-only checks
(`make validate`).
