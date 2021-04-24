---
layout: post
title: AWS Budget Alert
date: 2021-04-24 12:30:00 +0600
tags: aws budget
---

# Introduction

AWS Free Tier is quite generous about various services. But once it expires
expenses can go quite high pretty quickly. So for saving yourself from unexpected
surprises and unknown expenses setting up a budget alert is a `Must Do` task.

# Setting Up Via Console

Setting up a Budget Alert is quite simple. Search and select `AWS Budgets` from
the search bar, select `AWS Budgets` then press `Create a budget` from `AWS
Budget` dashboard.

![AWS Budget Alert - Dashboard]({{site.image_cdn_root}}/aws-budget-alert-01.png)

Then follow these steps to create budget.

### Step 1: Selecting Budget Type
First step is to select what type of budget you want to create. For getting
reminder based on cost, need to select `Cost Budget`.

![AWS Budget Alert - Step 1]({{site.image_cdn_root}}/aws-budget-alert-02.png)

### Step 2: Setting up Budget
Then need to enter all the details about budget. Following screen shot will
create a __recurring__ monthly budget of __10 USD__ named `Monthly AWS Expense`.

![AWS Budget Alert - Step 2]({{site.image_cdn_root}}/aws-budget-alert-03.png)

### Step 3: Configuring Thresholds
Now have to configure when and how to get alert. Following screen shot will email at
`aws-budget-alert@example.com` when 80% of Monthly Budget (i.e. __8 USD__) is
spent.

![AWS Budget Alert - Step 3]({{site.image_cdn_root}}/aws-budget-alert-04.png)

### Step 4: Confirming Budget
Now review all information then Press `Create` to complete the settings.

![AWS Budget Alert - Step 4]({{site.image_cdn_root}}/aws-budget-alert-05.png)

# Setting Up Via CLI

Now to configure budget alert from CLI, we need the account id. You can collect
it from web or if CLI is configured correctly following query will return
account details.

{% highlight shell %}
$ aws sts get-caller-identity 
{
    "UserId": "<UserId>",
    "Account": "<AccountId>",
    "Arn": "arn:aws:iam::<AccountID>:user/<UserName>"
}
{% endhighlight %}

with `--query` options we can filter only Account information. This will return
Account Id with double quotes (") around it. Striping that with `tr` and storing
it in an environment variable.

{% highlight shell %}
$ AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account | tr -d \")
{% endhighlight %}

Executing long commands is quite cumbersome but `--generate-cli-skeleton` can
generate template JSON for input. Running this command will generate
following output.

{% highlight shell %}
$ aws budgets create-budget --generate-cli-skeleton

{
    "AccountId": "",
    "Budget": {
        "BudgetName": "",
        "BudgetLimit": {
            "Amount": "",
            "Unit": ""
        },
        "PlannedBudgetLimits": {
            "KeyName": {
                "Amount": "",
                "Unit": ""
            }
        },
        "CostFilters": {
            "KeyName": [
                ""
            ]
        },
        "CostTypes": {
            "IncludeTax": true,
            "IncludeSubscription": true,
            "UseBlended": true,
            "IncludeRefund": true,
            "IncludeCredit": true,
            "IncludeUpfront": true,
            "IncludeRecurring": true,
            "IncludeOtherSubscription": true,
            "IncludeSupport": true,
            "IncludeDiscount": true,
            "UseAmortized": true
        },
        "TimeUnit": "DAILY",
        "TimePeriod": {
            "Start": "1970-01-01T00:00:00",
            "End": "1970-01-01T00:00:00"
        },
        "CalculatedSpend": {
            "ActualSpend": {
                "Amount": "",
                "Unit": ""
            },
            "ForecastedSpend": {
                "Amount": "",
                "Unit": ""
            }
        },
        "BudgetType": "USAGE",
        "LastUpdatedTime": "1970-01-01T00:00:00"
    },
    "NotificationsWithSubscribers": [
        {
            "Notification": {
                "NotificationType": "FORECASTED",
                "ComparisonOperator": "LESS_THAN",
                "Threshold": null,
                "ThresholdType": "ABSOLUTE_VALUE",
                "NotificationState": "ALARM"
            },
            "Subscribers": [
                {
                    "SubscriptionType": "SNS",
                    "Address": ""
                }
            ]
        }
    ]
}
{% endhighlight %}

From that JSON template I created `budget.json` and `subscriber.json` files 
with following data.

{% highlight shell %}
$ cat budget.json 
{
    "BudgetName": "AWS Monthly Expense",
    "BudgetLimit": {
        "Amount": "10",
        "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
}

$ cat subscriber.json
[
    {
        "Notification": {
            "NotificationType": "ACTUAL",
            "ComparisonOperator": "GREATER_THAN",
            "Threshold": 80,
            "ThresholdType": "PERCENTAGE"
        },
        "Subscribers": [
            {
                "SubscriptionType": "EMAIL",
                "Address": "aws-budget-alert@example.com"
            }
        ]
    }
]

{% endhighlight %}

Now running following command will create a Budget Alert similar to the one
create using console.

{% highlight shell %}
$ aws budgets create-budget \
     --account-id $AWS_ACCOUNT_ID \
     --budget file://budget.json \
     --notifications-with-subscribers file://subscriber.json
{% endhighlight %}

# Resource
* [AWS Budgets CLI Guide](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/budgets/index.html)