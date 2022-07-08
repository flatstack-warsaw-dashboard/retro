# Retro service

This is application for performing team retrospectives.
Application is build on top of AWS services and deployed by [Terraform](https://www.terraform.io/) utility.

## Repo structure

`/client` - js client for SPA

`/functions` - path containing lambdas for Api Gateway endpoints

`/retro` - gem containing domain objects and shared logic

## Deploying changes

To deploy application you should just run `terraform apply` in repo root path.
This command will create required AWS resources, build js client, ruby gem and deploy all lambdas to the cloud.

## Usage notes

Each part of application can contain own .tf files describing related resources. 
Such files should be included in `main.tf` file as Terraform module.

You can run ruby console and interact with DynamoDB records via:
`cd ./retro && AWS_PROFILE="your_profile_name" bin/console`
After this you will be awailable to access model objects (Example: list all users via command `Retro::User.all`)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flatstack-warsaw-dashboard/retro.

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
