require 'spec_helper'

if ENV['DISABLE_OPENSSL'] != '1'
  describe PostfixStatusLine do
    let(:options) do
      {mask: true}
    end

    subject { PostfixStatusLine.parse(status_line, options) }

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

    {
        1 => "86c53c0fc7e7f7d4b68e319d565611cc6c2c5b5b",
      224 => "e6c755638c48f2d7adbaf18d55f28e4f530e6048b90039086ff55369",
      256 => "af98201bf3272656988624c31e38828b51bb1a5b55fa11844de00e9701f2cba3",
      384 => "20fce738af5954a39d3128d213a027590f2a57ba05e98d5160d0e2ba2ab7f7b6063758282377ecacb0085ed7526e0532",
      512 => "f275e00cdebc8ae2e85e632cd9ad1e795c631f10c91058f880693ba1c4f3c28029e642ebb2b73050bd0e0123d8a8a4513946c5832f12f14ab2338482bd703799",
    }.each do |algorithm, hash_value|
      context "with hash (sha#{algorithm})" do
        let(:status_line) do
         'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, conn_use=2, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)'
        end

        let(:options) do
          {hash: true, salt: 'my_salt', sha_algorithm: algorithm}
        end

        it do
          is_expected.to eq({
            "conn_use" => 2,
            "delay" => 0.57,
            "delays" => "0.11/0.03/0.23/0.19",
            "domain" => "bellsouth.net",
            "dsn" => "2.0.0",
            "hash" => hash_value,
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

    context 'with hash (invalid algorithm)' do
      let(:status_line) do
       'Feb 27 09:02:37 MyHOSTNAME postfix/smtp[26490]: D53A72713E5: to=<myemail@bellsouth.net>, relay=gateway-f1.isp.att.net[204.127.217.16]:25, conn_use=2, delay=0.57, delays=0.11/0.03/0.23/0.19, dsn=2.0.0, status=sent (250 ok ; id=20120227140036M0700qer4ne)'
      end

      let(:options) do
        {hash: true, salt: 'my_salt', sha_algorithm: 123}
      end

      it do
        expect {
          subject
        }.to raise_error('Invalid SHA algorithm')
      end
    end
  end
end
