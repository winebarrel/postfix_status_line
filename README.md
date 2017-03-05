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

### Specify SHA algorithm

```ruby
PostfixStatusLine.parse(status_line, hash: true, sha_algorithm: 256)
```

### Parse time

```ruby
PostfixStatusLine.parse(status_line, parse_time: true)
```

### Parse [header_checks](http://www.postfix.org/header_checks.5.html) warning

```ruby
warning = "Mar  4 14:44:19 P788 postfix/cleanup[7426]: E80A9DF6F7E: warning: header Subject: test from local; from=<sugawara@P788.local> to=<sgwr_dts@yahoo.co.jp>"

PostfixStatusLine.parse_header_checks_warning(warning)
# => {
#      "time"=>"Mar  4 14:44:19",
#      "hostname"=>"P788",
#      "process"=>"postfix/cleanup[7426]",
#      "queue_id"=>"E80A9DF6F7E",
#      "to"=>"********@yahoo.co.jp",
#      "domain"=>"yahoo.co.jp",
#      "from"=>"********@P788.local",
#      "Subject"=>"test from local;"
#    }
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
  psl_t: {parse_time: true},
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

### Result

```
                           user     system      total        real
02:26:06 psl(1):       2.810000   0.000000   2.810000 (  2.807900)
02:26:09 psl(2):       2.820000   0.000000   2.820000 (  2.819920)
02:26:12 psl(3):       2.810000   0.000000   2.810000 (  2.809408)
02:26:14 psl(4):       2.810000   0.000000   2.810000 (  2.810345)
02:26:17 psl(5):       2.800000   0.000000   2.800000 (  2.802439)
>sec/prs:              0.000006   0.000000   0.000006 (  0.000006)
>prs/sec:            177935.943060        Inf        Inf (177935.783843)
                           user     system      total        real
02:26:20 psl_m(1):     2.940000   0.000000   2.940000 (  2.942580)
02:26:23 psl_m(2):     2.880000   0.000000   2.880000 (  2.879812)
02:26:26 psl_m(3):     2.900000   0.000000   2.900000 (  2.900414)
02:26:29 psl_m(4):     2.840000   0.000000   2.840000 (  2.836515)
02:26:32 psl_m(5):     2.790000   0.000000   2.790000 (  2.792500)
>sec/prs:              0.000006   0.000000   0.000006 (  0.000006)
>prs/sec:            174216.027875        Inf        Inf (174193.923151)
                           user     system      total        real
02:26:34 psl_h(1):     4.990000   0.000000   4.990000 (  4.987470)
02:26:39 psl_h(2):     5.000000   0.000000   5.000000 (  4.999526)
02:26:44 psl_h(3):     4.950000   0.000000   4.950000 (  4.944881)
02:26:49 psl_h(4):     5.030000   0.000000   5.030000 (  5.033834)
02:26:54 psl_h(5):     5.010000   0.000000   5.010000 (  5.031988)
>sec/prs:              0.000010   0.000000   0.000010 (  0.000010)
>prs/sec:            100080.064051        Inf        Inf (100009.204039)
                           user     system      total        real
02:26:59 psl_t(1):     4.060000   0.340000   4.400000 (  4.397266)
02:27:04 psl_t(2):     3.900000   0.320000   4.220000 (  4.226741)
02:27:08 psl_t(3):     3.750000   0.380000   4.130000 (  4.125684)
02:27:12 psl_t(4):     3.830000   0.280000   4.110000 (  4.097343)
02:27:16 psl_t(5):     3.770000   0.320000   4.090000 (  4.097630)
>sec/prs:              0.000008   0.000001   0.000008 (  0.000008)
>prs/sec:            129466.597618 1524390.243902        Inf (119362.140704)
```
