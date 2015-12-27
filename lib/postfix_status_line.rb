require 'postfix_status_line/version'
require 'postfix_status_line_core'

module PostfixStatusLine
  def parse(str, options = {})
    mask = options.has_key?(:mask) ? options[:mask] : true
    hash = options[:hash]
    salt = options[:salt]
    parse_time = options[:parse_time]
    PostfixStatusLine::Core.parse(str, mask, hash, salt, parse_time)
  end
  module_function :parse
end
