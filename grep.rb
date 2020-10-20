# frozen_string_literal: true

class Grep
  class << self
    def grep(pattern, flags, files)
      Grep.new(pattern, flags, files).grep
    end
  end

  def initialize(pattern, flags, files)
    @pattern = pattern
    @flags = flags
    @files = files
  end

  def grep
    file_name_to_lines
      .map { |file_name, lines| grep_file(file_name, lines, build_regex) }
      .compact
      .join("\n")
      .strip
  end

  private

  attr_reader :pattern, :flags, :files

  def file_name_to_lines
    files.each_with_object({}) do |file_name, file_name_to_lines|
      file_name_to_lines[file_name] = lines(file_name)
    end
  end

  def lines(file_name)
    file = File.open('file_namdse.txsd')
    file.readlines.map(&:chomp)
    file.close
  rescue Errno::ENOENT
    p "#{file_name} is not found"
    []
  end

  def grep_file(file_name, lines, regex)
    return handle_l_flag(file_name, lines, regex) if flags.include?('-l')

    lines.each_with_index.map do |line, index|
      if match_pattern(line, regex)
        "#{beginning_of_line(file_name)}#{position_of_line(index)}#{line}"
      end
    end.compact.join("\n")
  end

  def match_pattern(line, regex)
    if flags.include?('-v')
      !line.match(regex)
    else
      line.match(regex)
    end
  end

  def build_regex
    regex_body = "#{full_match_regex}#{pattern}#{full_match_regex(true)}"
    if flags.include?('-i')
      /#{regex_body}/i
    else
      /#{regex_body}/
    end
  end

  def handle_l_flag(file_name, lines, regex)
    lines.any? { |line| match_pattern(line, regex) } ? file_name : ''
  end

  def beginning_of_line(file_name)
    files.size > 1 ? "#{file_name}:" : ''
  end

  def position_of_line(index)
    flags.include?('-n') ? "#{index + 1}:" : ''
  end

  def full_match_regex(end_of_regex = false)
    chr = end_of_regex ? '$' : '^'
    flags.include?('-x') ? chr : ''
  end
end

#
# -n Print the line numbers of each matching line.
# -l Print only the names of files that contain at least one matching line.
# -i Match line using a case-insensitive comparison.
# -v Invert the program -- collect all lines that fail to match the pattern.
# -x Only match entire lines, instead of lines that contain a match.
#
