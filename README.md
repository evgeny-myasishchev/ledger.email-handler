# Ledger Email Handler Service  [<img src="https://travis-ci.org/evgeny-myasishchev/ledger.email-handler.svg?branch=master" alt="Build Status" />](https://travis-ci.org/evgeny-myasishchev/ledger.email-handler)

Service that parses bank emails with transactions and submits pending transactions to ledger

# Configuring

Adding mapping of bank account to ledger account.
First see ids of each ledger account for given user:
```
rake show-ledger-accounts[user@gmail.com]
```

Then for each bank account add mapping to ledger account. Bank account is the one that will be in the email
```
rake add-account-mapping[user@gmail.com,1111,3d2e57ac-0418-41aa-ad63-4ef08063915f]
```

Adding email config to get emails from:
```
rake add-email-config[ledger-user,BIC,'{"pop3":{"address":"pop.gmail.com"\,"port"
:995\,"account":"user@gmail.com"\,"password":"password"}}']
```

Where:
* ledger-user - user email of ledger user
* BIC - BIC of the bank 
* settings: provider specific JSON settings. At this point pop3 only is supported.

### Pop3 provider settings
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

To invoke worker that will handle emails of all configured users and submit them to ledger as pending transactions:
```
rake handle-emails
```

# Contributing
## Before push

```rubocop && rspec spec```
