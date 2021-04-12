---
layout: post
title: Installing AWS CLI v2
date: 2021-01-18 20:30:00 +0600
tags: aws cli
---

# Introduction

I started learning AWS 2-3 times before, but each time I became overwhelm by the
quantity and uncountable features of services. So it become required to take
note and write something down. Either I can take screenshot of AWS console and
write side note or learn Command Line Interface (CLI) and write commands. Later
is easier and future proof as AWS console UI changes quite frequently (Not sure
about CLI changes though!).

AWS CLI is an open source tool which provides similar functionally like AWS
Management Console at launch time or within 180 days of launch. It is written in
Python and has 2 versions. Version 2.x is latest and ready for production
environment. It's not backward compatible with Version 1.x.

# Installing Command Line Interface v2

I will be installing on Linux Mint 19 for testing aws cli. Following is my
Operating System details

{% highlight shell %}
$ lsb_release -a
Distributor ID:	LinuxMint
Description:	Linux Mint 19 Tara
Release:	19
Codename:	tara
{% endhighlight %}

Installation is done following
[this](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
link. Following commands will download, unzip and install AWS CLI. By default it
installs everything in `/usr/local/aws-cli` directory and creates symbolic link in
`/usr/local/bin`.

{% highlight shell %}
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install
{% endhighlight %}

Default install location and binary location can be changed using following
command.

{% highlight shell %}
$ aws ./aws/install --install-dir /home/$USER/aws-cli --bin-dir /home/$USER/.bin
{% endhighlight %}

All AWS actions are run through `aws` command. If installed successfully will be
able to run following command.

{% highlight shell %}
$ aws --version
aws-cli/2.0.2 Python/3.7.3 Linux/4.15.0-20-generic botocore/2.0.0dev6
{% endhighlight %}

# Configuration

For using AWS form CLI user must have access key. User can easily create access
key from `My Security Credentials` page's 'Access keys (access key ID and secret
access key)' panel. See
[details](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)
on access key document page.

To configure AWS run the following command,

{% highlight shell %}
$ aws configure
AWS Access Key ID [None]: <access-key>
AWS Secret Access Key [None]: <secret-key>
Default region name [None]: us-east-1
Default output format [None]: text
{% endhighlight %}

This will configure default profile with default region and output format.
Currently supported output formats are __json__, __text__, __table__, __yaml__,
__yaml-stream__.


Default region and output format will be saved in `~/.aws/config` file and
access key and secret will be store in `~/.aws/credentials` file.

{% highlight shell %}
$ cat ~/.aws/config
[default]
region = us-east-1
output = text

$ cat ~/.aws/credentials
aws_access_key_id = <access-key>
aws_secret_access_key = <secret-key>
{% endhighlight %}

You can access multiple account from same CLI using profile. For configuring
profile `--profile` flag is used. This will prompt for access key and secret
like before.

{% highlight shell %}
$ aws --profile <any-name> configure
{% endhighlight %}

Default profile, region or output format can be changed using `--profile`,
`--region` and `--output` flag. Following command will override default values
and will run `commands` in us-east-2 region and will output in json format.

{% highlight shell %}
$ aws --profile john-dev --region us-east-2 --output json <command>
{% endhighlight %}

# Command Syntax

Following is the basic syntax of `aws` command. `<command>` is usually name of
some service like `ec2`, `s3`, `iam` and `<subcommand>` are some action like
`create`, `delete`, `enable`, `disable` on those services.

{% highlight shell %}
$ aws [option] <command> <subcommand> [parameters]
{% endhighlight %}

# Example

Following query will fetch all amazon's EC2 images and output as table format

{% highlight shell %}
$ aws --output table ec2 describe-images --filter "Name=owner-alias,Values=amazon"
{% endhighlight %}

Following query will will ask for data to create new user. `--cli-auto-prompt`
will automatically ask for parameters:

{% highlight shell %}
$ aws iam create-user --cli-auto-prompt
{% endhighlight %}

Some commands supports `--dry-run`. This won't perform the final action/task but
will check everything. Following command will test starting condition of an EC2
instance.

{% highlight shell %}
$ aws ec2 start-instances --instance-ids <ids> --dry-run
{% endhighlight %}

# Help

AWS CLI has a great `help` support. Running `help` command after any command
will show a comprehensive help on that command. Following common will show the
main page of help. It will display global configs and options.

{% highlight shell %}
$ aws help
{% endhighlight %}

Following command will list all `s3` sub commands and show details help on all
s3 global options.

{% highlight shell %}
$ aws s3 help
{% endhighlight %}

If details on some sub command is needed then run `help` after that command.
Following will show detailed help with example on `s3 ls`.

{% highlight shell %}
$ aws s3 ls help
{% endhighlight %}

# Tools Version
* aws-cli/2.0.2 Python/3.7.3 Linux/4.15.0-20-generic botocore/2.0.0dev6

# Resource
* [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)