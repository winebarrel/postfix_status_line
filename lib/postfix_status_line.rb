require 'postfix_status_line/version'
require 'postfix_status_line_core'

module PostfixStatusLine
  def parse(str, mask = true)
    Core.parse(str, mask)
  end
  module_function :parse
end
