# ExAws.SigV4a

AWS Signature Version 4A (SigV4a) support for [ExAws](https://github.com/ex-aws/ex_aws).

SigV4a is an extension of AWS Signature Version 4 (SigV4) that enables signing requests across multiple AWS regions. This is particularly useful for:
- S3 Multi-Region Access Points
- Amazon SES global endpoints
- Other AWS services that support multi-region operations

## Installation

Add `ex_aws_sigv4a` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_aws_sigv4a, "~> 0.1.0"},
    {:ex_aws, "~> 2.0"},
    {:jason, "~> 1.3"}
  ]
end
```

## Usage

### Basic Usage

```elixir
# S3 multi-region access point
ExAws.S3.list_objects("my-multi-region-access-point")
|> ExAws.SigV4a.request(region_set: "*")

# Get object from S3
ExAws.S3.get_object("bucket", "key")
|> ExAws.SigV4a.request(region_set: "*")
```

### Specifying Multiple Regions

```elixir
config = [
  region_set: ["us-east-1", "us-west-2"],
  access_key_id: "AKIAIOSFODNN7EXAMPLE",
  secret_access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
]

ExAws.S3.get_object("bucket", "key")
|> ExAws.SigV4a.request(config)
```

## Testing

Run the test suite:

```bash
mix test
```

## Links

- [ExAws](https://github.com/ex-aws/ex_aws) - AWS client for Elixir
- [aws_signature](https://hex.pm/packages/aws_signature) - AWS signature calculation library
- [AWS SigV4a Documentation](https://docs.aws.amazon.com/general/latest/gr/signature-version-4.html)
