# Security

This is a demo project, but if you spot something worth flagging please do.

## Reporting

Open a private security advisory through the repository's **Security** tab,
or email the maintainer. Please don't open a public issue for anything
sensitive.

## Notes

- Credentials (AWS and Tigris) come from the environment or AWS Secrets
  Manager; nothing secret is committed to the repo.
- SSH and admin ports are scoped to your own IP via `my_ip_address`.
