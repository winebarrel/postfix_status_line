require 'spec_helper'

describe PostfixStatusLine do
  let(:options) do
    {mask: true}
  end

  subject { PostfixStatusLine.parse(status_line, options) }

  context 'with mask' do
    let(:status_line) do
     'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, conn_use=2, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)'
    end

    it do
      is_expected.to eq({
        "conn_use" => 2,
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
        "to" => "*******@bellsouth.net",
      })
    end
  end

  context 'with hash' do
    let(:status_line) do
     'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, conn_use=2, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)'
    end

    let(:options) do
      {hash: true, salt: 'my_salt'}
    end

    it do
      is_expected.to eq({
        "conn_use" => 2,
        "delay" => 0.57,
        "delays" => "0.11/0.03/0.23/0.19",
        "domain" => "bellsouth.net",
        "dsn" => "2.0.0",
        "hash" => "f275e00cdebc8ae2e85e632cd9ad1e795c631f10c91058f880693ba1c4f3c28029e642ebb2b73050bd0e0123d8a8a4513946c5832f12f14ab2338482bd703799",
        "hostname" => "MyHOSTNAME",
        "process" => "postfix/smtp[26490]",
        "queue_id" => "D53A72713E5",
        "status_detail" => "(250 ok ; id=20120227140036M0700qer4ne)",
        "relay" => "gateway-f1.isp.att.net[204.127.217.16]:25",
        "status" => "sent",
        "time" => "Feb 27 09:02:37",
        "to" => "*******@bellsouth.net",
      })
    end
  end

  context 'with hash (without salt)' do
    let(:status_line) do
     'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, conn_use=2, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)'
    end

    let(:options) do
      {hash: true}
    end

    it do
      is_expected.to eq({
        "conn_use" => 2,
        "delay" => 0.57,
        "delays" => "0.11/0.03/0.23/0.19",
        "domain" => "bellsouth.net",
        "dsn" => "2.0.0",
        "hash" => "1fd05ed207d708e32c924536eebc1006d56351184a793a768ee506d997395b2f89558e3ae5bd11227f1159f170e36975c480b78e35c6d1616f4983bfe6bdc947",
        "hostname" => "MyHOSTNAME",
        "process" => "postfix/smtp[26490]",
        "queue_id" => "D53A72713E5",
        "status_detail" => "(250 ok ; id=20120227140036M0700qer4ne)",
        "relay" => "gateway-f1.isp.att.net[204.127.217.16]:25",
        "status" => "sent",
        "time" => "Feb 27 09:02:37",
        "to" => "*******@bellsouth.net",
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
        "to" => "*******@bellsouth.net",
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
        "to" => "*******@bellsouth.net",
      })
    end
  end

  context 'without mask' do
    let(:status_line) do
     'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, conn_use=2, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)'
    end

    let(:options) do
      {mask: false}
    end

    it do
      is_expected.to eq({
        "conn_use" => 2,
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
        "to" => "myemail@bellsouth.net",
      })
    end
  end

  context 'when expired' do
    let(:status_line) do
      'May 29 19:21:17 testserver postfix/qmgr[4833]: 9D7FE1D0051: from=<root@test.hogehoge>, status=expired, returned to sender'
    end

    it do
      is_expected.to eq({
        "from" => "****@test.hogehoge",
        "hostname" => "testserver",
        "process" => "postfix/qmgr[4833]",
        "queue_id" => "9D7FE1D0051",
        "status" => "expired",
        "status_detail" => " returned to sender",
        "time" => "May 29 19:21:17",
      })
    end
  end

  context 'when parse time' do
    let(:status_line) do
     'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, conn_use=2, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)'
    end

    let(:options) do
      {parse_time: true}
    end

    it do
      is_expected.to eq({
        "conn_use" => 2,
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
        "time" => 1424995357,
        "to" => "*******@bellsouth.net",
      })
    end
  end
end
