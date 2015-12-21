require 'postfix_status_line/version'
require 'postfix_status_line_core'

module PostfixStatusLine
  def parse(str)
    Core.parse(str)
  end
  module_function :parse
end
