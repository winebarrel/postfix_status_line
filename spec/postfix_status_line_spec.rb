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
        "dsn" => "2.0.0",
        "hostname" => "MyHOSTNAME",
        "process" => "postfix/smtp[26490]",
        "queue_id" => "D53A72713E5",
        "relay" => "gateway-f1.isp.att.net[204.127.217.16]:25",
        "status" => "sent (250 ok ; id=20120227140036M0700qer4ne)",
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
        "dsn" => "2.0.0",
        "hostname" => "MyHOSTNAME",
        "process" => "postfix/smtp[26490]",
        "queue_id" => "D53A72713E5",
        "relay" => "gateway-f1.isp.att.net[204.127.217.16]:25",
        "status" => "sent (250 ok ; id=20120227140036M0700qer4ne)",
        "time" => "Feb 27 09:02:37",
        "to" => "<myemail@bellsouth.net>",
      })
    end
  end
end
