# frozen_string_literal: true

require File.join(File.dirname(__FILE__), "helper")
module Modules
  class TestTypeParser < Minitest::Test
    def examples
      {
        "2312" => 2312,
        "12-12-2012" => Date.new(2012, 12, 12),
        "12-12-2012 12:24" => DateTime.new(2012, 12, 12, 12, 24),
        "2012-12-12 12:24" => DateTime.new(2012, 12, 12, 12, 24),
        "2011-05-19T15_37_49 - 52349.xml" => "2011-05-19T15_37_49 - 52349.xml",
        "20-2-2012 20:52" => DateTime.new(2012, 2, 20, 20, 52),
        "1-11-2011" => Date.new(2011, 11, 1),
        "12/12/2012" => Date.new(2012, 12, 12),
        # "12/23/1980"=>Date.new(1980,12,23), #TODO: should probably depend on locale, see: http://bugs.ruby-lang.org/issues/634#note-10
        "jA" => "jA",
        "n" => "n",
        "" => nil,
        " " => nil,
        "12 bomen" => "12 bomen",
        "12 bomenasdfasdfsadf" => "12 bomenasdfasdfsadf",
        "mailto:sadf@asdf.as" => "sadf@asdf.as",
        "012-3456789" => "012-3456789",
        "TRUE" => true,
      }
    end

    def test_parse
      examples.each do |k, v|
        if v.nil?
          assert_nil(Workbook::Cell.new(k).parse({detect_date: true}))
        else
          assert_equal(v, Workbook::Cell.new(k).parse({detect_date: true}))
        end
      end
    end

    def test_custom_parse
      customparsers = [proc { |v| "#{v}2" }]
      examples.each do |k, v|
        c = Workbook::Cell.new(k)
        c.string_parsers = customparsers
        refute_equal(v, c.parse)
      end
      c = Workbook::Cell.new("233")
      c.string_parsers = customparsers
      assert_equal("2332", c.parse)
      c.value = "v"
      assert_equal("v2", c.parse)
    end

    def test_parse!
      r = Workbook::Row.new
      r[0] = Workbook::Cell.new "xls_cell"
      r[0].parse!
      assert_equal("xls_cell", r[0].value)
      r[1] = Workbook::Cell.new ""
      r[1].parse!
      assert_nil(r[1].value)
    end

    def test_once_failing_files
      w = Workbook::Book.open(File.join(File.dirname(__FILE__), "artifacts/failing_import1.xls")) # TRUE wasn't parsed properly
      assert_equal(Workbook::Book, w.class)
    end
  end
end
