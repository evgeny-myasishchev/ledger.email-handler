# Ledger Email Handler Service  [<img src="https://travis-ci.org/evgeny-myasishchev/ledger.email-handler.svg?branch=master" alt="Build Status" />](https://travis-ci.org/evgeny-myasishchev/ledger.email-handler)

Service that parses bank emails with transactions and submits pending transactions to ledger

# Deployment Dependencies

## Environment Variables
* **GOAUTH_CLIENT_ID** - client if of the offline app that will be used to get id_token of the user. This must be added to JWT_AUD_WHITELIST of ledger
* **GOOGLE_CLIENT_SECRET** - corresponding secret

For local testing purposes config/settings.local.yml can be created and values above can be placed there. See config structure here: config/settings.yml.

# Configuring

**Note:** You may need to set **RUBY_ENV=staging|production** first.

## Adding tokens of users:
Generate url to get access code
```
rake get-auth-code-url
```

Then open the URL in the browser, authorize with your google account (which must be registered ledger user) and copy provided access code.

Then invoke following task with the code from step above. This will get and add access/id tokens for your user so it will be able to call ledger api:
```
rake add-token[PASTE YOUR TOKEN HERE]
```

## Mapping Bank Accounts to Ledger Accounts

While parsing your email the parser needs to know ledger account that corresponds to your bank account. Follow steps below to configure such mapping for each user.

First see ids of each ledger account for given user:
```
rake show-ledger-accounts[user@gmail.com]
```

Then for each bank account add mapping to ledger account. Bank account is the one that will be in the email
```
rake add-account-mapping[user@gmail.com,1111,3d2e57ac-0418-41aa-ad63-4ef08063915f]
```

## Email providers

Email provider config to get emails from needs to be configured. It can be done with a following command:
```
rake add-email-config[ledger-user,BIC,'{"pop3":{"address":"pop.gmail.com"\,"port"
:995\,"account":"user@gmail.com"\,"password":"password"}}']
```

Where:
* ledger-user - user email of ledger user
* BIC - BIC of the bank 
* settings: provider specific JSON settings. At this point pop3 only is supported.

### Pop3 provider settings in detail
```
{
    "pop3": {
      "address": "pop.gmail.com",
      "port":: 995, #Pop3 port. Default 995
      "requires_ssl": true, # Optional, default true
      "account": "name@gmail.com",
      "password": "password",
      "autoremove": false # Optional, default false. Note: set to true if your provider will fetch again previously fetched.
    }
}
```

# Invoking

To invoke worker that will use provider to fetch emails then parse them and submit and submit to ledger as pending transactions:
```
rake handle-emails
```

You can schedule this command with cron to have this done on a schedule.

# Contributing
## Before push

```rubocop && rspec spec```
