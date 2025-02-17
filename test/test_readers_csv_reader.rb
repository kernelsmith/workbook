# frozen_string_literal: true

require File.join(File.dirname(__FILE__), "helper")
module Readers
  class TestCsvWriter < Minitest::Test
    def test_open
      w = Workbook::Book.new
      w.import File.join(File.dirname(__FILE__), "artifacts/simple_csv.csv")
      # reads
      #       a,b,c,d
      #       1,2,3,4
      #       5,3,2,1
      #       "asdf",123,12,2001-02-02
      #
      assert_equal([:a, :b, :c, :d], w.sheet.table.header.to_symbols)
      assert_equal(3, w.sheet.table[2][:b].value)
      assert_equal("asdf", w.sheet.table[3][:a].value)
      assert_equal(Date.new(2001, 2, 2), w.sheet.table[3][:d].value)
    end

    def test_excel_csv_open
      w = Workbook::Book.new
      w.import File.join(File.dirname(__FILE__), "artifacts/simple_excel_csv.csv")
      # reads
      #   a;b;c
      #   1-1-2001;23;1
      #   asdf;23;asd
      #   23;asdf;sadf
      #   12;23;12-02-2011 12:23
      #   12 asadf; 6/12 ovk getekend teru...; 6/12
      # y w.sheet.table
      assert_equal([:a, :b, :c], w.sheet.table.header.to_symbols)
      assert_equal(23, w.sheet.table[2][:b].value)
      assert_equal("sadf", w.sheet.table[3][:c].value)
      assert_equal(Date.new(2001, 1, 1), w.sheet.table[1][:a].value)
      assert_equal(DateTime.new(2011, 2, 12, 12, 23), w.sheet.table[4][:c].value)
      assert_equal("6/12 ovk getekend terugontv.+>acq ter tekening. 13/12 ovk getekend terugontv.+>Fred ter tekening.", w.sheet.table[5][:b].value)
      assert_equal("6/12", w.sheet.table[5][:c].value)
    end

    def test_excel_standardized_open
      w = Workbook::Book.new
      w.import File.join(File.dirname(__FILE__), "artifacts/excel_different_types.csv")
      # reads
      #   a,b,c,d
      # 2012-02-22,2014-12-27,2012-11-23,2012-11-12T04:20:00+00:00
      # c,222.0,,0027-12-14T05:21:00+00:00
      # 2012-01-22T11:00:00+00:00,42000.0,"goh, idd",ls

      assert_equal([:a, :b, :c, :d], w.sheet.table.header.to_symbols)
      assert_equal(Date.new(2012, 2, 22), w.sheet.table[1][:a].value)
      assert_equal("c", w.sheet.table[2][:a].value)
      assert_equal(DateTime.new(2012, 1, 22, 11), w.sheet.table[3][:a].value)
      assert_equal(42000, w.sheet.table[3][:b].value)
      assert_nil(w.sheet.table[2][:c].value)
    end

    def test_class_read_string
      s = File.read File.join(File.dirname(__FILE__), "artifacts/simple_csv.csv")
      w = Workbook::Book.read(s, :csv)
      # reads
      #       a,b,c,d
      #       1,2,3,4
      #       5,3,2,1
      #       "asdf",123,12,2001-02-02
      #
      assert_equal([:a, :b, :c, :d], w.sheet.table.header.to_symbols)
      assert_equal(3, w.sheet.table[2][:b].value)
      assert_equal("asdf", w.sheet.table[3][:a].value)
      assert_equal(Date.new(2001, 2, 2), w.sheet.table[3][:d].value)
    end

    def test_instance_read_string
      w = Workbook::Book.new
      s = File.read File.join(File.dirname(__FILE__), "artifacts/simple_csv.csv")
      w.read(s, :csv)
      # reads
      #       a,b,c,d
      #       1,2,3,4
      #       5,3,2,1
      #       "asdf",123,12,2001-02-02
      #
      assert_equal([:a, :b, :c, :d], w.sheet.table.header.to_symbols)
      assert_equal(3, w.sheet.table[2][:b].value)
      assert_equal("asdf", w.sheet.table[3][:a].value)
      assert_equal(Date.new(2001, 2, 2), w.sheet.table[3][:d].value)
    end

    def test_instance_read_stringio
      w = Workbook::Book.new
      sio = StringIO.new(File.read(File.join(File.dirname(__FILE__), "artifacts/simple_csv.csv")))
      w.read(sio, :csv)
      # reads
      #       a,b,c,d
      #       1,2,3,4
      #       5,3,2,1
      #       "asdf",123,12,2001-02-02
      #
      assert_equal([:a, :b, :c, :d], w.sheet.table.header.to_symbols)
      assert_equal(3, w.sheet.table[2][:b].value)
      assert_equal("asdf", w.sheet.table[3][:a].value)
      assert_equal(Date.new(2001, 2, 2), w.sheet.table[3][:d].value)
    end

    def test_from_string
      w = Workbook::Book.read("2013-03-19,JV,211,032,1,DBG A,,13,0147,\n", :csv, {converters: []})
      assert_equal("2013-03-19,JV,211,032,1,DBG A,,13,0147,\n", w.sheet.table.to_csv)
    end

    def test_semi_colon_separated_csv
      w = Workbook::Book.open(File.join(File.dirname(__FILE__), "artifacts/semicolonseparated_in_csv.csv"))
      assert_equal("﻿artikel,aantal,bedrag,reservering,aanmaaktijd_reservering,gastnummer,titel,voorletters,tussenvoegsels,naam,straat,huisnummer,postcode,woonplaats,email,tel_land,tel_net,tel_abon\nVriend - € 50,1,50.0,123,2016-10-27,7891,asdf,A.,,asdf,asdf ,55,1234 LM,AMSTERDAM,a@example.com,43,,123123\nVriend - € 35,1,35.0,123,2016-11-02,5676,Dasdfr,B.,,asdf,asdf asdf,12,1234 NN,UTRECHT,b@example.com,31,60,123123\n", w.sheet.table.to_csv)
    end
  end
end
