require 'spec_helper'

if ENV['DISABLE_OPENSSL'] != '1'
  describe PostfixStatusLine do
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
  end
end
