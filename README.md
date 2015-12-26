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

## Benchmark (on EC2/t2.micro)

### Script

```ruby
#!/usr/bin/env ruby
require 'benchmark'
require 'postfix_status_line'

it = 5
n = 500000

status_lines = "Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)"

{
  psl: {mask: false},
  psl_m: {},
  psl_h: {hash: true},
}.each do |name, options|
  Benchmark.bm(20, ">sec/prs:", ">prs/sec:") do |x|
    rs = []

    it.times do |i|
      i += 1

      rs << x.report("#{Time.now.strftime('%X')} #{name}(#{i}):") do
        for i in 1..n
          PostfixStatusLine.parse(status_lines, options)
        end
      end
    end

    pps = rs.inject(&:+) / it / n
    tp = Benchmark::Tms.new(1/pps.utime, 1/pps.stime, 1/pps.cutime, 1/pps.cstime, 1/pps.real)
    [pps, tp]
  end
end
```

## Result

```
                           user     system      total        real
05:31:58 psl(1):       2.800000   0.000000   2.800000 (  2.797415)
05:32:01 psl(2):       2.940000   0.000000   2.940000 (  2.939321)
05:32:04 psl(3):       2.780000   0.000000   2.780000 (  2.788848)
05:32:06 psl(4):       2.790000   0.000000   2.790000 (  2.794293)
05:32:09 psl(5):       2.800000   0.000000   2.800000 (  2.803760)
>sec/prs:              0.000006   0.000000   0.000006 (  0.000006)
>prs/sec:            177179.305457        Inf        Inf (177008.231192)
                           user     system      total        real
05:32:12 psl_m(1):     2.900000   0.000000   2.900000 (  2.901139)
05:32:15 psl_m(2):     2.900000   0.000000   2.900000 (  2.895323)
05:32:18 psl_m(3):     2.800000   0.000000   2.800000 (  2.804208)
05:32:21 psl_m(4):     2.770000   0.000000   2.770000 (  2.776839)
05:32:23 psl_m(5):     2.800000   0.000000   2.800000 (  2.796404)
>sec/prs:              0.000006   0.000000   0.000006 (  0.000006)
>prs/sec:            176429.075512        Inf        Inf (176380.363599)
                           user     system      total        real
05:32:26 psl_h(1):     5.330000   0.010000   5.340000 (  5.334204)
05:32:31 psl_h(2):     5.210000   0.000000   5.210000 (  5.207830)
05:32:37 psl_h(3):     5.220000   0.000000   5.220000 (  5.223716)
05:32:42 psl_h(4):     5.240000   0.000000   5.240000 (  5.242565)
05:32:47 psl_h(5):     5.200000   0.000000   5.200000 (  5.196516)
>sec/prs:              0.000010   0.000000   0.000010 (  0.000010)
>prs/sec:            95419.847328 250000000.000000        Inf (95402.257144)
```
```
