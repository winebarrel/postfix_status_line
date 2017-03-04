require 'spec_helper'

describe PostfixStatusLine do
  let(:options) do
    {mask: true}
  end

  subject { PostfixStatusLine.parse_header_checks_warning(header_checks_warning, options) }

  context 'with mask' do
    let(:header_checks_warning) do
      'Mar  4 14:44:19 P788 postfix/cleanup[7426]: E80A9DF6F7E: warning: header To: sgwr_dts@yahoo.co.jp from local; from=<sugawara@P788.local> to=<sgwr_dts@yahoo.co.jp>'
    end

    it do
      is_expected.to eq({
        "To" => "********@yahoo.co.jp from local;",
        "domain" => "yahoo.co.jp",
        "from" => "********@P788.local",
        "hostname" => "P788",
        "process" => "postfix/cleanup[7426]",
        "queue_id" => "E80A9DF6F7E",
        "time" => "Mar  4 14:44:19",
        "to" => "********@yahoo.co.jp",
      })
    end
  end

  context 'without mask' do
    let(:header_checks_warning) do
      'Mar  4 14:44:19 P788 postfix/cleanup[7426]: E80A9DF6F7E: warning: header To: sgwr_dts@yahoo.co.jp from local; from=<sugawara@P788.local> to=<sgwr_dts@yahoo.co.jp>'
    end

    let(:options) do
      {mask: false}
    end

    it do
      is_expected.to eq({
        "To" => "sgwr_dts@yahoo.co.jp from local;",
        "domain" => "yahoo.co.jp",
        "from" => "sugawara@P788.local",
        "hostname" => "P788",
        "process" => "postfix/cleanup[7426]",
        "queue_id" => "E80A9DF6F7E",
        "time" => "Mar  4 14:44:19",
        "to" => "sgwr_dts@yahoo.co.jp",
      })
    end
  end


  context 'when parse_time' do
    let(:header_checks_warning) do
      'Mar  4 14:44:19 P788 postfix/cleanup[7426]: E80A9DF6F7E: warning: header To: sgwr_dts@yahoo.co.jp from local; from=<sugawara@P788.local> to=<sgwr_dts@yahoo.co.jp>'
    end

    let(:options) do
      {parse_time: true}
    end

    it do
      is_expected.to eq({
        "To" => "********@yahoo.co.jp from local;",
        "domain" => "yahoo.co.jp",
        "from" => "********@P788.local",
        "hostname" => "P788",
        "process" => "postfix/cleanup[7426]",
        "queue_id" => "E80A9DF6F7E",
        "time" => "Mar  4 14:44:19",
        "epoch" => Time.parse('03/04 14:44:19 +0000').to_i,
        "to" => "********@yahoo.co.jp",
      })
    end
  end

  context 'when empty line' do
    let(:header_checks_warning) do
      ''
    end

    it do
      is_expected.to be_nil
    end
  end

  context 'when invalid line' do
    let(:header_checks_warning) do
      ':'
    end

    it do
      is_expected.to be_nil
    end
  end
end
