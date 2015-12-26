# PostfixStatusLine

Postfix Status Line Log Parser implemented by C.

[![Build Status](https://travis-ci.org/winebarrel/postfix_status_line.svg?branch=master)](https://travis-ci.org/winebarrel/postfix_status_line)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'postfix_status_line'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install postfix_status_line

## Usage

```ruby
require "postfix_status_line"

status_line = "Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, conn_use=2, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)"

PostfixStatusLine.parse(status_line)
# => {
#      "conn_use" => 2,
#      "delay" => 0.57,
#      "delays" => "0.11/0.03/0.23/0.19",
#      "dsn" => "2.0.0",
#      "hostname" => "MyHOSTNAME",
#      "process" => "postfix/smtp[26490]",
#      "queue_id" => "D53A72713E5",
#      "relay" => "gateway-f1.isp.att.net[204.127.217.16]:25",
#      "status" => "sent",
#      "status_detail" => "(250 ok ; id=20120227140036M0700qer4ne)",
#      "time" => "Feb  8 09:02:37",
#      "to" => "*******@bellsouth.net",
#      "domain" => "bellsouth.net"
#    }
```

### Include "to" mail address SH512 hash

```ruby
PostfixStatusLine.parse(status_line, hash: true)
```
