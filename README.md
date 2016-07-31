# Ledger Email Handler Service  [<img src="https://travis-ci.org/evgeny-myasishchev/ledger.email-handler.svg?branch=master" alt="Build Status" />](https://travis-ci.org/evgeny-myasishchev/ledger.email-handler)

Service that parses bank emails with transactions and submits pending transactions to ledger

# Configuring

Adding email config to get emails from:
```
rake add_email_config[ledger-user,BIC,'{"pop3":{"address":"pop.gmail.com"\,"port"
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


# Contributing
## Before push

```rubocop && rspec spec```
