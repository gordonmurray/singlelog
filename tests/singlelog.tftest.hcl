# Plan-level tests. Both providers are mocked, so this runs a real plan without
# AWS credentials and without calling Tigris. The point is to catch a provider
# upgrade that changes a default or drops an argument before it reaches a real
# apply, and to keep the security choices below from being undone by accident.
#
# `terraform test` evaluates file(), which `terraform validate` does not, so
# ssh_public_key_path points at a throwaway key. `make test` generates it.

mock_provider "aws" {
  # The instance role policy is built from this ARN. Pinning it keeps the ARN
  # known at plan time so the policy document can be asserted on below.
  mock_resource "aws_secretsmanager_secret" {
    defaults = {
      arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:singlelog/tigris-AbCdEf"
    }
  }
}

mock_provider "tigris" {}

variables {
  vpc_id              = "vpc-0123456789abcdef0"
  subnet_id           = "subnet-0123456789abcdef0"
  aws_account_id      = "123456789012"
  my_ip_address       = "203.0.113.10"
  ssh_public_key_path = "tests/fixtures/id_rsa.pub"
  tigris_access_key   = "test-access-key"
  tigris_secret_key   = "test-secret-key"
}

run "instances_are_hardened" {
  command = plan

  assert {
    condition = alltrue([
      for i in [aws_instance.nginx, aws_instance.clickhouse] :
      i.metadata_options[0].http_tokens == "required"
    ])
    error_message = "Both instances must require IMDSv2"
  }

  assert {
    condition = alltrue([
      for i in [aws_instance.nginx, aws_instance.clickhouse] :
      i.root_block_device[0].encrypted
    ])
    error_message = "Both root volumes must be encrypted"
  }

  assert {
    condition     = aws_instance.clickhouse.instance_type == "t4g.medium"
    error_message = "ClickHouse should stay on Graviton, which is what keeps the bill near $37/mo"
  }
}

run "only_http_is_open_to_the_world" {
  command = plan

  # SSH and the ClickHouse ports are the ones that must never widen. Ports 80
  # and 443 on the nginx demo box are public on purpose.
  assert {
    condition = alltrue([
      for r in [
        aws_security_group_rule.nginx_ssh,
        aws_security_group_rule.clickhouse_ssh,
        aws_security_group_rule.clickhouse_http,
        aws_security_group_rule.clickhouse_native,
      ] : length(r.cidr_blocks) == 1 && contains(r.cidr_blocks, "${var.my_ip_address}/32")
    ])
    error_message = "SSH and the ClickHouse ports must stay scoped to my_ip_address"
  }
}

run "the_log_bucket_is_private" {
  command = plan

  assert {
    condition     = tigris_bucket_public_access.logs.acl == "private"
    error_message = "The log bucket must not be public"
  }

  assert {
    condition     = tigris_bucket_public_access.logs.public_list_objects == false
    error_message = "The log bucket must not allow public listing"
  }
}

run "instances_can_read_only_the_tigris_secret" {
  # apply rather than plan: the policy is built from the secret ARN, which is
  # only filled in from the mock above once the (mocked) resource is created.
  # Every provider here is mocked, so nothing is really created.
  command = apply

  # The 2022 version had a wildcard S3 write policy. This keeps the replacement
  # narrow: one action, one secret.
  assert {
    condition = alltrue([
      for s in jsondecode(aws_iam_role_policy.read_tigris_secret.policy).Statement :
      s.Action == ["secretsmanager:GetSecretValue"]
    ])
    error_message = "The instance role must only be able to read a secret"
  }

  assert {
    condition     = aws_secretsmanager_secret.tigris.name == var.tigris_secret_name
    error_message = "The instances read the secret by name, so it must match the variable"
  }
}
