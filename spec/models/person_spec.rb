# encoding: utf-8

require 'spec_helper'

describe Person do
  it  "#short_name" do
    person = Person.new("должность", "Петров Иван Сергеевич")
    person.short_name.should == "Петров И.С."
  end
end
