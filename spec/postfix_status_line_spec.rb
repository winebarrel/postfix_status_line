require 'spec_helper'

describe PostfixStatusLine do
  let(:status_line) do
   'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)'
  end

  let(:mask) { true }

  subject { PostfixStatusLine.parse(status_line, mask) }

  context 'with mask' do
    it do
      is_expected.to eq({
        "delay" => 0.57,
        "delays" => "0.11/0.03/0.23/0.19",
        "domain" => "bellsouth.net",
        "dsn" => "2.0.0",
        "hostname" => "MyHOSTNAME",
        "process" => "postfix/smtp[26490]",
        "queue_id" => "D53A72713E5",
        "status_detail" => "(250 ok ; id=20120227140036M0700qer4ne)",
        "relay" => "gateway-f1.isp.att.net[204.127.217.16]:25",
        "status" => "sent",
        "time" => "Feb 27 09:02:37",
        "to" => "<*******@bellsouth.net>",
      })
    end
  end

  context 'when include "<" and extra' do
    let(:status_line) do
     'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok < id=20120227140036M0700qer4ne), extra=<youremail@bellsouth.com>'
    end

    it do
      is_expected.to eq({
        "delay" => 0.57,
        "delays" => "0.11/0.03/0.23/0.19",
        "domain" => "bellsouth.net",
        "dsn" => "2.0.0",
        "extra" => "<*********@bellsouth.com>",
        "hostname" => "MyHOSTNAME",
        "process" => "postfix/smtp[26490]",
        "queue_id" => "D53A72713E5",
        "status_detail" => "(250 ok < id=20120227140036M0700qer4ne)",
        "relay" => "gateway-f1.isp.att.net[204.127.217.16]:25",
        "status" => "sent",
        "time" => "Feb 27 09:02:37",
        "to" => "<*******@bellsouth.net>",
      })
    end
  end

  context 'when include email in status_detail' do
    let(:status_line) do
     'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne foo@example.com (bar@example.com)), extra=<youremail@bellsouth.com>'
    end

    it do
      is_expected.to eq({
        "delay" => 0.57,
        "delays" => "0.11/0.03/0.23/0.19",
        "domain" => "bellsouth.net",
        "dsn" => "2.0.0",
        "extra" => "<*********@bellsouth.com>",
        "hostname" => "MyHOSTNAME",
        "process" => "postfix/smtp[26490]",
        "queue_id" => "D53A72713E5",
        "status_detail" => "(250 ok ; id=20120227140036M0700qer4ne ***@example.com (***@example.com))",
        "relay" => "gateway-f1.isp.att.net[204.127.217.16]:25",
        "status" => "sent",
        "time" => "Feb 27 09:02:37",
        "to" => "<*******@bellsouth.net>",
      })
    end
  end

  context 'without mask' do
    let(:mask) { false }

    it do
      is_expected.to eq({
        "delay" => 0.57,
        "delays" => "0.11/0.03/0.23/0.19",
        "domain" => "bellsouth.net",
        "dsn" => "2.0.0",
        "hostname" => "MyHOSTNAME",
        "process" => "postfix/smtp[26490]",
        "queue_id" => "D53A72713E5",
        "status_detail" => "(250 ok ; id=20120227140036M0700qer4ne)",
        "relay" => "gateway-f1.isp.att.net[204.127.217.16]:25",
        "status" => "sent",
        "time" => "Feb 27 09:02:37",
        "to" => "<myemail@bellsouth.net>",
      })
    end
  end

  context 'when expired' do
    let(:status_line) do
      'May 29 19:21:17 testserver postfix/qmgr[4833]: 9D7FE1D0051: from=<root@test.hogehoge>, status=expired, returned to sender'
    end

    it do
      is_expected.to eq({
        "from" => "<****@test.hogehoge>",
        "hostname" => "testserver",
        "process" => "postfix/qmgr[4833]",
        "queue_id" => "9D7FE1D0051",
        "status" => "expired",
        "status_detail" => " returned to sender",
        "time" => "May 29 19:21:17",
      })
    end
  end
end
