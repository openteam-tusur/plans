# encoding: utf-8

require 'spec_helper'

describe Person do
  it  "#short_name" do
    person = Person.new("Петров Иван Сергеевич",  "должность")
    person.short_name.should == "Петров И.С."
  end
end
